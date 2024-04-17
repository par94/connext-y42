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
# for more information check out our docs: https://docs.y42.dev/docs/sources/ingest-data-using-python

async def post_slipppage(domain, tokenAddress, endpoint, tokenIndexFrom, tokenIndexTo, amount):
    url = "https://sdk-server.mainnet.connext.ninja/calculateSwap"

    data = {
        "domainId": str(domain),
        "tokenAddress": str(tokenAddress),
        "tokenIndexFrom": str(tokenIndexFrom),
        "tokenIndexTo": str(tokenIndexTo),
        "amount": str(amount),
        "options": {
            "originProviderUrl": str(endpoint)
            }
    }

    # Convert the dictionary to a JSON string
    data_json = json.dumps(data)

    # Set the appropriate headers for JSON data
    headers = {'Content-Type': 'application/json'}

    # Sending the POST request
    #response = requests.post(url, data=data_json, headers=headers)

    # Checking the response

    try:
        response = await asyncio.to_thread(requests.post, url, headers=headers, data=data_json)
        response.raise_for_status()  # Raise an exception for HTTP errors (e.g., 404, 500)
        #data = response.json()
        data = response

        if response.status_code == 200:
            print("Success:", response.text)
            # Step 2: Parse the string as JSON
            data = json.loads(response.text)
            print(data['hex'])

            # Step 3: Extract the hexadecimal value
            hex_value = data['hex']

            # Step 4: Convert the hexadecimal value to an integer
            int_value = int(hex_value, 16)

            print(int_value)

            slippage = (1-int_value/amount)*100
            print(slippage)

            return slippage

        else:
            print("Error:", response.status_code, response.text)
    except requests.exceptions.RequestException as e:
            # Handle request-related errors (e.g., network issues, timeout)
        print(f"Error: {e}")
        return None

@data_loader
async def slippage_monitoring(context) -> pd.DataFrame:
    #httpx==0.26.0
    # Reference secrets if needed
    #all_secrets = context.secrets.all() # get all secrets saved within this space

    df = pd.DataFrame()

    assets = {
        "1634886255": #arb
        {
            "local": "0x2983bf5c334743Aa6657AD70A55041d720d225dB",
            "adopted": "0x82aF49447D8a07e3bd95BD0d56f35241523fBab1",
            "endpoint": "https://arbitrum-mainnet.infura.io/v3/7e94bd49053945d7bdc52884c58d9fe5"
        },
        "6450786": #bnb
        {
            "local": "0xA9CB51C666D2AF451d87442Be50747B31BB7d805",
            "adopted": "0x2170Ed0880ac9A755fd29B2688956BD959F933F8",
            "endpoint": "https://bsc-mainnet.blastapi.io/46b64ddd-127f-4145-b72d-3770f3927c96"
        },
        "1818848877": #linea
        {
            "local": "0x0573ad07ca4f74757e5b2417bf225bebebcf66d9",
            "adopted": "0xe5d7c2a44fffdf6b295a15c148167daaaf5cf34f",
            "endpoint": "https://linea-mainnet.blastapi.io/46b64ddd-127f-4145-b72d-3770f3927c96"
        },
        "1836016741": #mode
        {
            "local": "0x609aefb9fb2ee8f2fdad5dc48efb8fa4ee0e80fb",
            "adopted": "0x4200000000000000000000000000000000000006",
            "endpoint": "https://mode-mainnet.blastapi.io/46b64ddd-127f-4145-b72d-3770f3927c96"
        },
        "1650553709": #base
        {
            "local": "0xE08D4907b2C7aa5458aC86596b6D17B1feA03F7E",
            "adopted": "0x4200000000000000000000000000000000000006",
            "endpoint": "https://base-mainnet.blastapi.io/46b64ddd-127f-4145-b72d-3770f3927c96"
        }

    }
    timestamp = datetime.now(timezone.utc)
    amount_array = [10**17, 3*10**17, 10**18, 3*10**18, 10**19, 3*10**19, 10**20, 3*10**20, 10**21, 3*10**21]
    for amount in amount_array:

        #amount = 3*10**i

        for asset in assets:
            print(asset)
            print(assets[asset]['adopted'])
            print(amount)
            response = await post_slipppage(asset, assets[asset]['adopted'], assets[asset]['endpoint'], 1, 0, amount)
            combined_data = {
                "domain_id": asset,
                "asset": assets[asset]['adopted'],
                "amount": amount,
                "slippage": response,
                "timestamp": timestamp
            }
            temp_df = pd.DataFrame([combined_data])
            logging.info(combined_data)
            df = pd.concat([df, temp_df])

    print(df)
    df

    logging.info("Data fetched and DataFrame created successfully.")
    for column in df.columns:
        #df_expanded[column] = df_expanded[column].astype(str)
        if df[column].dtype == 'object':
            df[column]= df[column].fillna('')
            df[column] = df[column].astype(str)
    
    # to learn how to set up incremental updates and more
    # please visit https://docs.y42.dev/docs/sources/ingest-data-using-python
    return df
