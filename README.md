# Fast
Fast is a DevOps tool.

## Installation

Requirements:
 * ruby: 1.93
 * docker: 1.3.1

## Usage
Show help message
```
fast help
```
 
###Build
1.Goto the source
```
cd /home/component
```
2.Create .fast.yml, the idea comes from [.travis.yml](http://docs.travis-ci.com/user/build-configuration/), this is a example:
```
image: <docker registry>/component:latest

build:
 - env
 - scripts/test # the script to run test
```

* image: the docker image to run build
* build: the commands to run build

3.Run build
```
fast build /home/component
```
or,
```
WORKSPACE=/home/component fast-build 
``` 
Fast will pull the image and create a container, mount the workspace into the container and run build.
Also it will set ENV in the container:
* WORKSPACE: the mount point of workspace in the container
* OUTPUT: the dir of Output, you can put the test reports into Output

###Stage
Stage is similar to Build

1.Update .fast.yml
```
image: <docker registry>/component:latest

build:
 - env
 - scripts/test # the script to run test
 
stage:
 - env
 - scripts/packaing # the script to run packaing
```

2.Run stage
```
fast stage /home/component --output bin
```

## Contributing

1. Fork it 
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
