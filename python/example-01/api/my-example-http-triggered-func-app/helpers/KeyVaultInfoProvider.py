from typing import List
from .KeyVaultInfo import KeyVaultInfo
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient


class KeyVaultInfoProvider:
    vault_url_format = "https://{key_vault_name}.vault.azure.net/"
    credential = DefaultAzureCredential()

    def __init__(self, key_vault_names):
        self.key_vault_names = key_vault_names

    def get_secret_infos(self, secret_name) -> List[KeyVaultInfo]:       
        key_vault_infos = []
        for name in self.key_vault_names:
            secret_client = SecretClient(self.vault_url_format.format(key_vault_name=name), self.credential)
            secret = secret_client.get_secret(secret_name)
            key_vault_info = KeyVaultInfo(name, secret_name, secret.properties.created_on, secret.value)
            key_vault_infos.append(key_vault_info)

        return key_vault_infos
