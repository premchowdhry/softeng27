import pytest

@pytest.fixture(autouse=True)
def isolation(fn_isolation):
    pass

def test_transfer(accounts):
    accounts[0].transfer(accounts[1], "10 ether")
    assert accounts[1].balance() == "110 ether"

def test_isolated(accounts):
    assert accounts[1].balance() == "100 ether"
