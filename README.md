# Cribl log search

This app is written using [Sinatra](https://sinatrarb.com/), a simple DSL for quickly creating web applications in Ruby. 

## Features
- When requesting `/api/v1/logs` it  returns all the log files in the specified folder. The requirements mentions to search from `/var/logs`, but I have it pointed to files in the codebase for testing and implementation. The location could be changed easily with a config parameter for different environments.
- The API can take the following paramters:
   - filname: We can specify a filename and the app will return the last ten lines (the page size is configurable)
   - lines: We can specify how many lines we want to read from that file
   - q: We can specify a query param to search in that log file. The requirements don't specify how many lines we want to return, so if the file is huge, it's unnecessary to search the entire file. So, I gave the option to return how many lines we want to be returned, something similar to pagination
   - ignore_case: We can specify if we want case matching or not (by default case is ignored)
   - a sample URL will look like this `http://localhost:4567/api/v1/logs?filename=sample-1.log&lines=15&q=info&ignore_case=false`

## Running the app
- I included a Dockerfile so it's easy to start the app. After cloning the github app, 
```
> docker build --tag cribl-sarath .
> docker run -p 4567:4567 cribl-sarath
```
The app should be exposed at port `4567` now. I have used minitest to include unit tests. However, I was not successful in running the tests in docker bash and have spent more than four hours on this assignment. The tests can be run by itself with simple ruby command `ruby tests/server_test.rb` Let me know if you want to run in the docker environment and I can work on that.
