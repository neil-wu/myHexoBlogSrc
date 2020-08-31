#!/bin/bash

rsync --perms -avh --progress --delete --exclude=".git/*" ./public/  ../neil-wu.github.io/



