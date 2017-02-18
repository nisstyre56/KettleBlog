from __future__ import with_statement
from fabric.api import *
from fabric.contrib.console import confirm
from fabric.contrib.project import rsync_project
import fabric.operations as op

env.hosts = ["wes@mgoal.ca:444"]

@task
def buildTags():
    with lcd("./build"):
        local("riot ../src/tags scripts/tags.min.js")

@task
def buildScss():
    with lcd("./build"):
        local("sassc ../src/styles/riotblog.scss > styles/riotblog.min.css")

@task
def minifyJS():
    with lcd("./build"):
        local("uglifyjs ../src/scripts/riotblog.js > scripts/riotblog.min.js")

@task
def buildVenv():
    local("virtualenv -p $(which python3) ./venv")
    with prefix("source ./venv/bin/activate"):
        local("pip3 install -r requirements.txt")
    local("mv venv ./build/")

@task
def copyFiles():
    local("cp ./{blog.ini,blog.service} ./build/")
    local("cp ./src/*py ./build/")
    local("cp ./src/styles/*.css ./build/styles/")
    local("cp -r ./src/templates ./build/templates")

@task
def upload():
    run("mkdir -p ~/build")
    rsync_project(local_dir="./build/", remote_dir="~/build/", delete=True, exclude=[".git"])

@task
def serveUp():
    sudo("cp -r /home/wes/build /srv/riotblog")

@task(default=True)
def build():
    local("rm -r ./build")
    local("mkdir -p build/{scripts,styles}")
    buildTags()
    buildScss()
    minifyJS()
    buildVenv()
    copyFiles()
    upload()
    serveUp()