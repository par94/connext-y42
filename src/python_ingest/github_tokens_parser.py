import requests
import pandas as pd
import logging
import json

# use the @data_loader decorator to materialize an asset
# make sure you have a corresponding .yml table definition matching the function's name
# for more information check out our docs: https://docs.y42.dev/docs/sources/ingest-data-using-python

@data_loader
def github_tokens_parser(context) -> pd.DataFrame:
    # Reference secrets if needed
    all_secrets = context.secrets.all() # get all secrets saved within this space
    one_secret = context.secrets.get('<SECRET_NAME>') # get the value of a specific secret saved within this space

    # Your code goes here
    url = "https://github.com/connext/chaindata/blob/main/crossChain.json"

    response = requests.get(url)
    logging.info(response)
    data = json.loads(response.content)
    logging.info(data)

    # Return a DataFrame which will be materialized within your data warehouse
    df = pd.DataFrame(data)
    logging.info(df)

    logging.info("Data fetched and DataFrame created successfully.")
    
    # to learn how to set up incremental updates and more
    # please visit https://docs.y42.dev/docs/sources/ingest-data-using-python
    return df
