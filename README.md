# PivotToJupyter
## Steps to perform demo
1) Clone Repo/Download files
2) Navigate to directory
3) docker compose up -d --build
4) Navigate to: http://localhost:61773/csp/user/_DeepSee.UI.Analyzer.zen?$NAMESPACE=USER&CUBE=HoleFoods.cube
5) Place some dimension on rows, DateOfSale for example
6) Select a cell that you would like to further analyze the data behind
7) Select PivotToJupyter custom action
8) After being navigated to the Jupyter notebook, play all cells


## Demo in action
Steps 1-3

![Setup Screenshot](https://github.com/psteiwer/PivotToJupyter/blob/main/Assets/Demo1.PNG)

Steps 5-7 (DateOfSale dragged to rows, cell for 2022 clicked, PivotToJupyer custom action selected

![Analyzer Screenshot](https://github.com/psteiwer/PivotToJupyter/blob/main/Assets/Demo2.PNG)

Step 8, play all cells and observe results

![Jupyter Screenshot](https://github.com/psteiwer/PivotToJupyter/blob/main/Assets/Demo3.PNG)
