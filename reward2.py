from brownie import *
p = project.load('token', name="TokenProject")
p.load_config()
from brownie.project.TokenProject import *
network.connect('development')
