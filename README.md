# Branch explanation

The purpose of this branch is to minimize the possibility of out of memory error that can occur when specified number of voxels in input file is too large (e.g. 800x800x400 or something similar, though this depends on computer architecture and available memory). More specifically, as program works with large objects, all RAM and virtual memory tends to be swallowed until the out of memory error occurs.

Even before this error occurs, a notable increase in program time (when increasing voxel number) can be seen already before the actual monte carlo light simulation starts to perform, as it can take several minutes to progress to this step. As I often require large number of voxels (e.g., to achieve greater precision), I have decided to find out what can be done regarding this problem.

Using matlab profiler and task manager in combination with matlab stepping functionality, I found that the large memory use increase occurs for this part of program: runMonteCarlo.m -> getOpticalMediaProperties.m -> smoothn.m

It should be noted that smoothn function, which represents the largest problem, is not always called, but only when smoothingLengthScale is larger than 0 and matchedInterfaces is equal to 0 (false). Also, after the mentioned functions are finished, that is, during the actual monte carlo light simulation and heat simulation, the memory usage is not that high.

When looking more thoroughly through smoothn.m file and while checking where out of memory error occurse exactly, I found the three problematic parts of code that swallow disproportionate amounts of memory:

1. tol = isweighted*norm(vec([z0{:}]-[z{:}]))/norm(vec([z{:}])); line. As this line is not time-intensiver (that is, it gets computed fast), I replaced this line with a for loop that is not so memory intensitive, while the simulation time increase was only negligible.
2. dctn (discrete cosine transform) and idctn (inverse discrete cosine transform) functions that are called multiple times through smoothn.m code. I found out that these function are both memory AND time intensive, therefore being the main culprit for the increase in program time that occurs even before simulation itself.

Also, the most time-intensive line inside dctn and idctn, as was determined with matlab profiler, tends to be y = ifft(y,[],1); line that performs inverse discrete fourier transform. However (though I am perhaps wrong), this line is apparently already highly optimized, as it calls some mex function that uses https://www.fftw.org/ library (a highly optimized C/C++ library for fast fourier transforms) or something like that.

Additionally, there are other lines in these two functions that tend to consume considerable amount of time. However, while playing with improving memory and time efficiency of these two functions for now, I wasnt able to make any noticeable progress. Therefore, for time being, I have written this text and leave things as they are, with a possibility that I will again try to deal with this problem when I will have more time. 