class KeyVaultInfo:
    def __init__(self, key_vault_name, secret_name, secret_creation_date, secret_value):
        self.key_vault_name = key_vault_name
        self.secret_name = secret_name
        self.secret_creation_date = secret_creation_date
        self.secret_value = secret_value

    def __str__(self):
        return f"Key Vault Name '{self.key_vault_name}', Secret Name '{self.secret_name}', Secret Creation Date '{self.secret_creation_date}', Secret Value '{self.secret_value}'"
