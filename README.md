# PivotToJupyter

## Using this demo
### Steps to perform demo
1) Clone Repo/Download files
2) Navigate to directory
3) docker compose up -d --build
4) Navigate to: http://localhost:61773/csp/user/_DeepSee.UI.Analyzer.zen?$NAMESPACE=USER&CUBE=HoleFoods.cube
5) Place some dimension on rows, DateOfSale for example
6) Select a cell that you would like to further analyze the data behind
7) Select PivotToJupyter custom action
8) After being navigated to the Jupyter notebook, play all cells


### Demo in action
Steps 1-3

![Setup Screenshot](https://github.com/psteiwer/PivotToJupyter/blob/main/Assets/Demo1.PNG)

Steps 5-7 (DateOfSale dragged to rows, cell for 2022 clicked, PivotToJupyer custom action selected

![Analyzer Screenshot](https://github.com/psteiwer/PivotToJupyter/blob/main/Assets/Demo2.PNG)

Step 8, play all cells and observe results

![Jupyter Screenshot](https://github.com/psteiwer/PivotToJupyter/blob/main/Assets/Demo3.PNG)

## Implementation Guide

There are two main components to this demo. The first is a custom action inside or IRIS BI. The second is a Jupyter notebook that uses data that was specified in the custom action.

### Custom Action
Custom Actions come from code that is implemented in a "KPI Action Class". This class is then pointed to by a cube so it can use the defined custom actions. In this example, the class ```PivotToJupyter.CustomKPIAction``` was created to implement the custom action. Inside of ```%OnDashboardAction```, there is logic to pull the current query context out of the pContext object so either the selected cell on the pivot table, or the context of the entire pivot table will be used. Once this context is extracted, a new table is created based on the Listing results of the current query context. Then, a python method, ```GenerateNotebook``` is executed to generate the notebook that queries this new table. Finally, it uses the "newWindow" command to open a new browser window that points to the notebook server running in the container with the newly generated notebook.

### Jupyter Notebook
The Dockerfile does two important steps for creating the notebook server:

```RUN python3 -m pip install notebook pandas matplotlib seaborn sqlalchemy-iris``` - this installs dependencies for both hosting the notebook server as well as installing the python libraries that the demo code in the generated notebook uses.

```CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=''", "--ServerApp.root_dir=/usr/irissys/mgr/user/notebooks"]``` - this tells the container to run the notebook server when the container is started. I also needed to implement ```entrypoint.sh``` to ensure that iris-main is still executed so IRIS also starts with the container.