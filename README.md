# UberTestDemo
Demo Application 

1. No Third Party Support is taken to build this Application
2. LocalCache could not support Persistent Storage. Use of FileManager to Support Caching is Done. FileManager is used as Images are large chunk of Data and should not be kept in Tables
3. Optimisation is done in Usage of Main Thread. 
4. Reading of Data From File Manager is on Background Thread 
5. Operation Queue is used for to download images in Operations. All Image Request are cancelled when search text is changed.
6. User cannot do same search if the results is there and can only get more result for the search.
7. Interactive UI in case of scroll
8. All Image Downloads are done on Operationqueue with help of Operations
10. Self Created Loader is Used
11. Error Screen and Result Screen for No result Found created.

