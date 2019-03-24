#!/bin/sh

clear
echo `date --rfc-3339=seconds`
vagrant up --provider=virtualbox
echo `date --rfc-3339=seconds`