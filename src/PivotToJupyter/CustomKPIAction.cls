Class PivotToJupyter.CustomKPIAction Extends %DeepSee.KPI
{

XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<kpi
xmlns="http://www.intersystems.com/deepsee/kpi"
 name="Holefoods Custom Actions">

<action name="PivotToJupyter"/>
</kpi>
}

ClassMethod %OnDashboardAction(pAction As %String, pContext As %ZEN.proxyObject) As %Status
{
	if (pAction="PivotToJupyter") {
        // Convert selected context to a new table
		Set tCurrFilterSpec = $P(pContext.currFilterSpec," ",2,*)
		Set tNewTableName = "PivotToJupyter."_pContext.cubeName_$translate($zdt($h,8)," :","")
		Set tSC = ##class(%DeepSee.ResultSet).%CreateTable(pContext.cubeName,tNewTableName,tCurrFilterSpec)

        // Create a new Jupyter notebook based on new table
        Do ..GenerateNotebook(tNewTableName)

        // Navigate to new Jupyter notebook
        Set pContext.command = "newWindow:http://localhost:61888/notebooks/"_tNewTableName_".ipynb"
	}

	quit $$$OK
}

ClassMethod UpdateActionClass()
{
    // Update actionClass for HoleFoods cube
    Set tSC=$$$OK
    Set tCube="HoleFoods"
    Set tActionClass="PivotToJupyter.CustomKPIAction"

    Set tCubeClass=##class(%DeepSee.Utils).%GetCubeClass(tCube)

    Set tModel=##class(%DeepSee.Utils).%GetModel(tCube)
    Set tModel.actionClass=tActionClass

    Set tSC=##class(%DeepSee.Utils).%SaveCubeDefinition(tCubeClass,,tModel.description,tModel)
    Quit:$$$ISERR(tSC) tSC
    Set tSC=$System.OBJ.Compile(tCubeClass,"fck /displayerror=0 /displaylog=0")
    Quit:$$$ISERR(tSC) tSC

    Quit tSC
}

ClassMethod GenerateNotebook(tNewTableName) [ Language = python ]
{
    import nbformat as nbf
    from pathlib import Path
    
    # Create a new notebook
    nb = nbf.v4.new_notebook()
    
    nb["metadata"]["kernelspec"] = {
        "name": "python3",
        "display_name": "Python 3",
        "language": "python"
    }
    
    # Add cells
    nb.cells = [
        nbf.v4.new_markdown_cell("# InterSystems IRIS BI - Dynamic Notebook Example\n"
                                "This notebook connects to an IRIS instance and queries the `"+tNewTableName+"` table."),
        nbf.v4.new_markdown_cell("## Prerequisites\n"
                                "- Install required packages:\n"
                                "```bash\n"
                                "pip install pyodbc pandas matplotlib seaborn sqlalchemy-iris\n"
                                "```\n"
                                "- Set up an ODBC DSN (e.g., `myirisdsn`) that connects to your IRIS instance."),
        nbf.v4.new_code_cell("import pandas as pd\nimport matplotlib.pyplot as plt\nimport seaborn as sns\nfrom sqlalchemy import create_engine"),
    
        nbf.v4.new_code_cell("# Set up the connection\n"
                            "user = '_SYSTEM'\n"
                            "password = 'SYS'\n"
                            "host = 'localhost'\n"
                            "port = 1972\n"
                            "namespace = 'USER'\n"
                            "engine = create_engine(f'iris://{user}:{password}@{host}:{port}/{namespace}')"),
        nbf.v4.new_code_cell("# Query the "+tNewTableName+" table\n"
                            "query = '''\n"
                            "SELECT * FROM "+tNewTableName+"\n"
                            "'''\n"
                            "df = pd.read_sql(query, engine)\n"
                            "df.head()"),
        nbf.v4.new_code_cell("# Check for missing values and summary statistics\n"
                            "print(df.isnull().sum())\n"
                            "df.describe()"),
        nbf.v4.new_code_cell("# Visualize total sales by product\n"
                            "sales_by_product = df.groupby('Product')['Revenue'].sum().reset_index()\n"
                            "plt.figure(figsize=(12,6))\n"
                            "sns.barplot(data=sales_by_product, x='Product', y='Revenue')\n"
                            "plt.title('Total Sales by Product')\n"
                            "plt.xticks(rotation=45)\n"
                            "plt.tight_layout()\n"
                            "plt.show()")
    ]

    # Save to local directory
    notebookDir = Path("notebooks")
    notebookDir.mkdir(parents=True, exist_ok=True)
    notebook_path = Path("notebooks",tNewTableName+".ipynb").resolve()
    with open(notebook_path, "w", encoding="utf-8") as f:
        nbf.write(nb, f)

    return
}

}
