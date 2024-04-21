from y42.v1.decorators import data_loader
import requests
import pandas as pd
import logging
import json
import re
import asyncio
from datetime import timezone, datetime

# use the @data_loader decorator to materialize an asset
# make sure you have a corresponding .yml table definition matching the function's name
# for more information check out our docs: https://www.y42.com/docs/sources/ingest-data-using-python

@data_loader
def Router_monitoring(context) -> pd.DataFrame:
    # Reference secrets if needed
    #all_secrets = context.secrets.all() # get all secrets saved within this space
    #one_secret = context.secrets.get('<SECRET_NAME>') # get the value of a specific secret saved within this space

    # Your code goes here
    routers = ['0x7ce49752ffa7055622f444df3c69598748cb2e5f',
    '0xc4ae07f276768a3b74ae8c47bc108a2af0e40eba',
    '0x6273c0965a1db4f8a6277d490b4fd48715a42b96',
    '0x49a9e7ec76bc8fdf658d09557305170d9f01d2fa',
    '0x22831e4f21ce65b33ef45df0e212b5bebf130e5a',
    '0x5d527765252003acee6545416f6a9c8d15ae8402',
    '0x6892d4d1f73a65b03063b7d78174dc6350fcc406',
    '0x96d38b113b1bc6a21d1137676f2f05dfcace24e8',
    '0x6fd84ba95525c4ccd218f2f16f646a08b4b0a598',
    '0x975574980a5da77f5c90bc92431835d91b73669e',
    '0x8cb19ce8eedf740389d428879a876a3b030b9170',
    '0xf26c772c0ff3a6036bddabdaba22cf65eca9f97c',
    '0x048a5ecc705c280b2248aeff88fd581abbeb8587',
    '0xbe7bc00382a50a711d037eaecad799bb8805dfa8',
    '0xfaab88015477493cfaa5dfaa533099c590876f21',
    '0x58507fed0cb11723dfb6848c92c59cf0bbeb9927',
    '0x33b2ad85f7dba818e719fb52095dc768e0ed93ec',
    '0x0e62f9fa1f9b3e49759dc94494f5bc37a83d1fad',
    '0x63cda9c42db542bb91a7175e38673cfb00d402b0',
    '0x88f02a786e33823b1217341fa8345136a05948bb',
    '0xeca085906cb531bdf1f87efa85c5be46aa5c9d2c',
    '0x97b9dcb1aa34fe5f12b728d9166ae353d1e7f5c4',
    '0x32d63da9f776891843c90787cec54ada23abd4c2',
    '0xba11aa59645a56031fedbccf60d4f111534f2502',
    '0x9584eb0356a380b25d7ed2c14c54de58a25f2581',
    '0xc770ec66052fe77ff2ef9edf9558236e2d1c41ef',
    '0x76cf58ce587bc928fcc5ad895555fd040e06c61a',
    '0x5f4e31f4f402e368743bf29954f80f7c4655ea68',
    '0xc82c7d826b1ed0b2a4e9a2be72b445416f901fd1',
    '0xb7318647071eb12164d251b07815154761967a8f']

    url = "https://sequencer.mainnet.connext.ninja/router-status/"

    for router in routers:
        logging.info(router)
        logging.info(url+router)
    
    #response = requests.get(url)
    #data = json.loads(response.content)

    # Return a DataFrame which will be materialized within your data warehouse
    df = pd.DataFrame()


    logging.info("Data fetched and DataFrame created successfully.")

    # to learn how to set up incremental updates and more
    # please visit https://www.y42.com/docs/sources/ingest-data-using-python
    return df
