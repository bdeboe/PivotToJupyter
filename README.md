# PivotToJupyter
Table of contents
  1. [Using this demo](#using-this-demo)
  2. [ZPM Install Steps Needed](#install-with-ZPM)
  3. [Implementation Guide](#implementation-guide)

## Using this demo
### Steps to perform demo
1) Clone Repo/Download files
2) Navigate to directory
3) docker compose up -d --build
    - Note: build can take a few minutes due to dependencies
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

## Install with ZPM
```zpm "install pivottojupyter"```

Installing with ZPM does not configure Python or the notebook server. It simply installs the demo KPI class. This means either the demo KPI will need to be modified for your configurations, or you will need to make configuration changes similar to what the container does.

The following python libraries are used: ```notebook pandas matplotlib seaborn sqlalchemy-iris```.

Manual configurations for a notebook server are also needed. The KPI expects a notebook server to be listening on port 61888 (it is actually listening on port 8888 in the container, but the container exposes this as 61888). The KPI also places generated notebook files in ```<install dir>/mgr/<namespace>/notebooks```, which means the notebook server needs to look in this directory for the files.

For extra details on how these are implemented in the container, continue reading the [Implementation Guide](#implementation-guide).


## Implementation Guide

There are two main components to this demo. The first is a custom action inside or IRIS BI. The second is a Jupyter notebook that uses data that was specified in the custom action.

### Custom Action
Custom Actions come from code that is implemented in a "KPI Action Class". This class is then pointed to by a cube so it can use the defined custom actions. In this example, the class ```PivotToJupyter.CustomKPIAction``` was created to implement the custom action. Inside of ```%OnDashboardAction```, there is logic to pull the current query context out of the pContext object so either the selected cell on the pivot table, or the context of the entire pivot table will be used. Once this context is extracted, a new table is created based on the Listing results of the current query context. Then, a python method, ```GenerateNotebook``` is executed to generate the notebook that queries this new table. Finally, it uses the "newWindow" command to open a new browser window that points to the notebook server running in the container with the newly generated notebook.

### Jupyter Notebook
The Dockerfile does two important steps for creating the notebook server:

```RUN python3 -m pip install notebook pandas matplotlib seaborn sqlalchemy-iris``` - this installs dependencies for both hosting the notebook server as well as installing the python libraries that the demo code in the generated notebook uses.

```CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=''", "--ServerApp.root_dir=/usr/irissys/mgr/user/notebooks"]``` - this tells the container to run the notebook server when the container is started. I also needed to implement ```entrypoint.sh``` to ensure that iris-main is still executed so IRIS also starts with the container.
Note that the custom action creates the notebook in a local folder, which is why we're starting Jupyter from inside the IRIS container rather than as a separate container.

:information_source: Note that the above command starts the Jupyter notebook app at port 8888, but the `docker-compose.yml` file wires that to 61888 on your host. You can customize the port to use for building the URL through `^PivotToJupyter("jupyter-port")` as required (see also `src/PivotToJupyter/CustomKPIAction.cls`). 