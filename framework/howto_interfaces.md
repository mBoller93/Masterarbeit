
# Building Casadi for Matlab, with CPLEX and/or Gurobi without sudo privileges

In this tutorial, we will store all results in the directory `$HOME/Tools`. Adjusting for your needs!
## 1.) Build custom SWIG, needed for building Casadi with Matlab interface

Decide on a directory on where to build and install swig. Here, we cd to `$HOME/Tools` and checkout swig into `$HOME/Tools/swig`

1.	Clone the repository and checkout the matlab-customdoc branch 
	`git clone https://github.com/jaeandersson/swig -b matlab-customdoc`

2.	cd into the newly created swig directory and run `sh autogen.sh`

3. 	Configure the package using `./configure --prefix=$HOME/Tools/swig/build`
	This will tell the compiler to install the compiled package into the subdirectory build

4.	Run `make && make install`

After these steps, you should find 2 directories within the newly created `build` directory, `bin` and `shared`.

## 2.) Install CPLEX

1.	Download CPLEX from https://www.ibm.com/de-de/products/ilog-cplex-optimization-studio (free account required).
2.	Follow the instructions of both the website and the installer (downloaded file must be `chmod +x`d and then run).
	Decide which directory you want to install CPLEX to.
3.	Add the following line to your `.bashrc` file and replace the paths with your CPLEX installation paths:
	~~~	
	export PATH=/opt/ibm/ILOG/CPLEX_Studio129/concert/include:/opt/ibm/ILOG/CPLEX_Studio129/cplex/include:/opt/ibm/ILOG/CPLEX_Studio129/cplex/lib/x86-64_linux/static_pic:/opt/ibm/ILOG/CPLEX_Studio129/concert/lib/x86-64_linux/static_pic:$PATH
	~~~
4. 	Either logout and log back in or run `source ~/.bashrc` to update the PATH variable for the current terminal session

## 3.) Install Gurobi
1.	Follow the instructions of the [Gurobi installation manual](http://www.gurobi.com/documentation/8.1/quickstart_linux/software_installation_guid.html#section:Installation)
	Make sure to set all environment variables and `source` the `.bashrc` file or logout and login again
2. 	Proceed to the [tutorial](http://www.gurobi.com/documentation/8.1/quickstart_linux/retrieving_and_setting_up_.html#section:RetrieveLicense) explaining how to retrieve your Gurobi licence, there is a free academic licence available

## 4.) Build Casadi

1.	`cd` into your `$HOME/Tools` and checkout the current version of casadi into `$HOME/Tools/casadi`:
	~~~	
	git clone https://github.com/casadi/casadi.git -b master casadi
	~~~

2.	(This step is requried at the time of writing this tutorial, with Casadi 3.4.5) If you want to install Casadi with the Gurobi interface, you must edit ` $HOME/Tools/casadi/cmake/FindGUROBI.cmake`. In the file, add the line `gurobi81` or `gurobiXX` (where `XX` corresponds to the build number of Gurobi that you have installed) directly _after_ the following lines:
	~~~
	find_library( GUROBI_LIBRARY 
              NAMES gurobi
	~~~

3.	Move into the directory `$HOME/Tools/casadi` and create a `build` directory
	~~~
	cd casadi
	mkdir build
	cd build
	~~~
4.	Now we generate a makefile with all our requirements (be sure not to omit the `..`):
	~~~
	cmake -DWITH_DEEPBIND=ON \
	      -DWITH_MATLAB=ON -DMATLAB_ROOT=YOUR_MATLAB_DIRECTORY \
	      -DSWIG_DIR=$HOME/Tools/swig/build/share/swig/YOUR_SWIG_VERSION/ \
	      -DSWIG_EXECUTABLE=$HOME/Tools/swig/build/bin/swig \
	      -DWITH_CPLEX=ON -DCPLEX=YOUR_CPLEX_DIRECTORY \
	      -DWITH_GUROBI=ON \
	      -DCMAKE_INSTALL_PREFIX:PATH=$HOME/casadi/build/ ..
	~~~

	Replace `YOUR_MATLAB_DIRECTORY`, `YOUR_SWIG_VERSION` and `YOUR_CPLEX_DIRECTORY` with the corresponding directories

5.	Run `make && make install`

## 5.) Add Casadi to Matlab
The previous build process should have created the Casadi Matlab plugin inside `$HOME/Tools/casadi/build/matlab`. In Matlab, use the `pathtool` to add this path to Matlabs paths permanently or use `addpath('~/Tools/casadi/build/matlab')`

You should now be able to use qpsol with 'cplex' and 'gurobi' as solver.

If you need more solvers, like IPOPT or BONMIN, follow the [Casadi installation manual](https://github.com/casadi/casadi/wiki/InstallationLinux) for that.

# Installing YALMIP with qpOASES and CPLEX

## 1.) Installing YALMIP
Installing YALMIP is considerably easier than with Casadi.
First, download YALMIP from [here](https://github.com/yalmip/yalmip/archive/master.zip). Unzip this to some good place.
This is everything you have to do for installing YALMIP itself.
To use it in Matlab, add it using:
~~~
addpath(genpath( your_yalmip_path) )
savepath
~~~
omit `savepath` if you don't want to add it permanently.

## 2.) Installing CPLEX
To install CPLEX, follow the directions from the other chapter.
Then, in matlab you need to `addpath` the path containing the CPLEX Matlab interface:
~~~
addpath( '/opt/ibm/ILOG/CPLEX_Studio129/cplex/matlab/x86-64_linux/' )
savepath
~~~

## 3.) Installing qpOASES
This step is a little more complicated, but not much.
1.	Download qpOASES from the [qpOASES project website](http://www.qpoases.org/go/release)
2.	Unzip it to some suitable directory
3.	Open Matlab and navigate to this directy, then the subdirectory `interfaces/matlab`
4.	Configure mex to compile using g++ by typing `mex -setup C++`
5.	Run `make`. This should compile the qpOASES Matlab extension. If this fails with the following message:
	~~~
	Error using mex
	/tmp/mex_3570552951384630_11260/qpOASES.o: In function
	`qpOASES::QProblemB::computeCholesky()':
	qpOASES.cpp:(.text+0xc289): undefined reference to `dpotrf_'
	/tmp/mex_3570552951384630_11260/qpOASES.o: In function
	`qpOASES::QProblem::computeProjectedCholesky()':
	qpOASES.cpp:(.text+0x16cf6): undefined reference to `dpotrf_'
	/tmp/mex_3570552951384630_11260/qpOASES.o: In function
	`qpOASES::SQProblemSchur::updateSchurQR(long)':
	qpOASES.cpp:(.text+0x3034e): undefined reference to `dtrcon_'
	/tmp/mex_3570552951384630_11260/qpOASES.o: In function
	`qpOASES::SQProblemSchur::backsolveSchurQR(long, double const*, long,
	double*)':
	qpOASES.cpp:(.text+0x304db): undefined reference to `dtrtrs_'
	collect2: error: ld returned 1 exit status 
	~~~
	Then open the `make.m` file, go to line 72 and add `lmwlapack` to CPPFLAGS:
	~~~
	CPPFLAGS = [ CPPFLAGS, '-DLINUX -lmwblas -lmwlapack',' ' ];
	~~~

	After that, just rerun `make`.  
	This may produce some warning messages relating so "snprintf". These warnings can be ignored, as they do not hinder the 	compilation and cause no further issues.
6.	Add the qpOASES Matlab extension to Matlab, again using addpath:
	~~~
	addpath( 'your_qpoases_directory/interfaces/matlab/' );
	savepath
	~~~

## 4.) test YALMIP
After you performed all the steps, you should be able to run `yalmiptest` in Matlab. This should tell you that CPLEX and qpOASES are installed and available, and will then also test whether they were correctly installed.
