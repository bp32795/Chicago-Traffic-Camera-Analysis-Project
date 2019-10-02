
# Chicago-Traffic-Camera-Analysis-Project

This was a master's capstone for an R class where a dataset had to be analyzed. This script takes data from 4 datasets located in the Chicago Data Portal. For my convenience, I combined them and made them publicly accessible online. That url is in the script. The four datasets are:

 - Red Light Camera Violations
 - Red Light Camera Locations
 - Speed Camera Violations
 - Speed Camera Locations

After these 4 are merged, the script will place each camera in a NESW district group. This part takes close to 4 hours, so it is recommended to run it once, export the `vio` dataframe to a csv, then comment out lines 24 to 69 and uncomment line 75. The script will then output 2 text files and 8 png files to the current working directory. The text files are a linear model and a tickets per camera type metric. Examples of some of the images are below:

 - Number and Type of Violations Map
	 - ![enter image description here](https://raw.githubusercontent.com/bp32795/Chicago-Traffic-Camera-Analysis-Project/master/examples/typeandviolations.png?_sm_au_=iHV5SJPJF5fFH50F)
 - Violations per Type Bar Graph
	 - ![enter image description here](https://raw.githubusercontent.com/bp32795/Chicago-Traffic-Camera-Analysis-Project/master/examples/typeandviolationsDays.png?_sm_au_=iHV5SJPJF5fFH50F)
 - Violations by Type by District
	 - ![*This would be better as a per camera metric, but that can be a later development.](https://raw.githubusercontent.com/bp32795/Chicago-Traffic-Camera-Analysis-Project/master/examples/DistrictBar.png?_sm_au_=iHV5SJPJF5fFH50F)

Lastly, this code is no longer maintained, but rather serves as a portfolio.
