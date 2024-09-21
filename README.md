# D is a simple Docker Helper

> d <cmd> [param1] [param2]

Think git for Docker.

Add a d.txt file to your project directory that contains two lines,
the first line contains your image name, the scond line the container name.

or in the project directory run:

> d create image_name container_name

This will create the file for you. Once this file is created you can then type:

> d go

d will use the d.txt file to build and run your image.

# My commands are:
```

Command(s)                     Description
----------                     -----------
h,help,-help                   shows this help file
help-examples                  shows how to use with example sessions
commands                       shows list of '-d' docker commands or '-oc' openshift commands                                   
ver,version                    show current version information                  
config:save                    save d configuration preferences. $1: "option:setting"
create                         create d file. $1: image name; $2: container name 
check,who                      manual check d.txt file data is valid             
which,inspect                  using current directory find any d files recursevely.  $1: optional path instead
build                          build docker image. $1 : image name               
sh                             open shell to container. Uses d file in current directory
do                             run a d file from anywhere. $1 : full d file path and name
go                             we can take over the whole workflow               
stop                           will stop the last run container hash we stored in the data file
log,logs                       will print logs from the container hash stored in data file
ps,running,active              list running containers                           
search,search                  containers","find-container" - find container with fuzzy searc
read,data                      read image and container name from data file      
open:browser,browser           open browser to http://0.0.0.0:80                 
open:hub                       open docker hub                                   
open:docker,start:docker       start the docker daemon                           
close,exit,goodbye             stop docker daemon                                
sound                          test sounds                                       
docs                           list of links to savailable docs                  
docs:steps                     list of steps using Docker                        
docs:docker                    open docker documentation                         
docs:docker:video              open docker documentation                         
docs:learn                     open Python learning documentation                
docs:fastapi                   open Fastapi documentation                        
docs:fasthtml                  open FastHTML documentation                       
docs:fasthtml:video            open FastHTML video                               
docs:ai                        open docker dataset agent image                   
docs:ai:agents                 open docker llama agents                          
saveus                         save data about this session                      
readus                         read saved sessions                               
list                           list all saved sessions                           
sessions                       list and pick a session                           
images                         list docker images -t: last seven days; -s with substring;                               
find,find                      image" - find image with fuzzy searc              
rebuild                        rebuild and rerun image. $1: image name; $2: container name
start                          start container                                   
run                            run docker image by name                          
persist                        run docker image by name in background            
rm,delete                      delete container                                  
containers                     list all containers                               
all,commands,cmds              list all docker commands                          
save                           save image and container name to data file        
save2                          save image and container name to data file        
load,last                      user can select which session to return to        
autodoc                        generate this document         
```