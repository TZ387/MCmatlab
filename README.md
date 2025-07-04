# Branch explanation

The purpose of this branch is to reduce the possibility of an out-of-memory error that can occur when the specified number of voxels in the input file is too large (e.g., 800x800x400 or something similar, though this depends on computer architecture and available memory). More specifically, as the program works with large objects, all RAM and virtual memory tend to be consumed until the out-of-memory error occurs.

Even before this error occurs, a notable increase in program time (when increasing the number of voxels) can be seen already before the actual Monte Carlo light simulation starts to run, as it can take several minutes to progress to this step. As I often require a large number of voxels (e.g., to achieve greater precision), I have decided to find out what can be done regarding this problem.

Using the MATLAB profiler and Task Manager in combination with MATLAB's stepping functionality, I found that the large increase in memory usage occurs in this part of the program: `runMonteCarlo.m -> getOpticalMediaProperties.m -> smoothn.m`.

It should be noted that the `smoothn` function, which represents the largest problem, is not always called—only when `smoothingLengthScale` is larger than 0 and `matchedInterfaces` is equal to 0 (false). Also, after the mentioned functions are finished—that is, during the actual Monte Carlo light simulation and heat simulation—the memory usage is not that high.

When looking more thoroughly through the `smoothn.m` file and checking where the out-of-memory error occurs exactly, I found three problematic parts of code that consume disproportionate amounts of memory:

1. `tol = isweighted*norm(vec([z0{:}]-[z{:}]))/norm(vec([z{:}]));` line. As this line is not time-intensive (that is, it gets computed fast), I replaced it with a `for` loop that is not so memory-intensive, with the simulation time only negligibly increasing.  
2. `dctn` (discrete cosine transform) and `idctn` (inverse discrete cosine transform) functions that are called multiple times throughout the `smoothn.m` code. I found that these functions are both memory- and time-intensive, therefore being the main culprit for the increase in program time that occurs even before the simulation itself.

Also, the most time-intensive line inside `dctn` and `idctn`, as determined with the MATLAB profiler, tends to be `y = ifft(y,[],1);`, a line that performs the inverse discrete Fourier transform. However (though I may be wrong), this line is apparently already highly optimized, as it calls a MEX function that uses the [FFTW](https://www.fftw.org/) library (a highly optimized C/C++ library for fast Fourier transforms) or something similar.

Additionally, there are other lines in these two functions that tend to consume a considerable amount of time. I am currently trying to achieve some time/memory improvement by exploring what can be done regarding these functions.
