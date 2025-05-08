# Keystone Container

Container leve baseado em Fedora para o serviço **Keystone (OpenStack Identity)**. Esta imagem instala e configura o Keystone de forma minimalista, utilizando uWSGI e permitindo a configuração por variáveis de ambiente.

---

## 📦 Imagem

- **Base:** Fedora 42
- **Keystone version:** 25.0.0 (2025.1 release)
- **Gerenciado via:** uWSGI
- **Banco de dados esperado:** MariaDB (MySQL)

---

## ⚙️ Build da imagem

Clone este repositório e execute:

```bash
podman build -f keystone-containerfile -t keystone:tag .
```

---

## 🚀 Execução do container com Podman

### 🛠️ Variáveis obrigatórias

| Variável               | Descrição                                    |
|------------------------|----------------------------------------------|
| `KEYSTONE_DB_HOST`     | Host do banco MariaDB                        |
| `KEYSTONE_DB_PASS`     | Senha do banco para o usuário `keystone`     |
| `KEYSTONE_ADMIN_PASS`  | Senha do usuário `admin` do Keystone         |
| `KEYSTONE_REGION`      | Nome da região (ex: `sp-east-1`)             |
| `KEYSTONE_HOSTNAME`    | Hostname usado para bootstrap dos endpoints  |

### 📘 Exemplo de execução

```bash
podman run -d --name keystone \
  -e KEYSTONE_DB_HOST=fqdn_database \
  -e KEYSTONE_DB_PASS=123db \
  -e KEYSTONE_ADMIN_PASS=SenhaAdminKeystone123! \
  -e KEYSTONE_REGION=sp-east-1 \
  -e KEYSTONE_HOSTNAME=fqdn_host \
  -v /opt/keystone:/var/lib/keystone:Z \
  -p 5000:5000 \
  keystone:tag
```

---

## 🧩 Componentes no container

- `keystone.conf` é gerado automaticamente com base nas variáveis de ambiente
- Banco de dados e cache apontam para o mesmo host (`KEYSTONE_DB_HOST`)
- `keystone-manage` é usado para:
  - Sincronizar o banco
  - Configurar Fernet
  - Executar o bootstrap com URL da API

---

## 📂 Volumes

Você pode mapear um volume persistente para o diretório `/var/lib/keystone`:

```bash
-v /opt/keystone:/var/lib/keystone:Z
```

---

## 📖 Logs

Logs padrão são enviados para `/var/log/keystone`, que podem ser acessados com:

```bash
podman logs -f keystone
```

---

## 🔐 Endpoints esperados após o bootstrap

- **Admin / Internal / Public URL**:  
  `http://${KEYSTONE_HOSTNAME}:5000/v3/`

---

## 🧼 Parar e remover o container

```bash
podman stop keystone && podman rm keystone
```

---

## 🛠️ Troubleshooting

- Certifique-se que o banco de dados MariaDB esteja acessível na rede
- Verifique se a senha de banco (`KEYSTONE_DB_PASS`) está correta
- Veja logs com `podman logs keystone` para entender erros de bootstrap

---

## 📜 Licença

MIT
