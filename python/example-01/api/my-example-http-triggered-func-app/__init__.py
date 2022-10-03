import logging
import azure.functions as func
from .helpers.KeyVaultInfoProvider import KeyVaultInfoProvider
from .helpers.KeyVaultInfo import KeyVaultInfo

# secret name = VaronisAssignmentSecret
key_vault_names = ["MyVaronisAssignmentKv1", "MyVaronisAssignmentKv2", "MyVaronisAssignmentKv3"] # Can be stored in config section of fumction app. Also key vault reference can be used to get a secret.

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    name = req.params.get('name')
    if not name:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            name = req_body.get('name')

    if name:
        try:
            key_vault_info_provider = KeyVaultInfoProvider(key_vault_names)
            key_vault_infos = key_vault_info_provider.get_secret_infos(name)

            content = ""
            for info in key_vault_infos:
                content += info.__str__() + "\n"

            print(content)  

            return func.HttpResponse(content)
        except Exception:
            return func.HttpResponse("Error occured")
    else:
        return func.HttpResponse(
            "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response.",
            status_code=200
        )
