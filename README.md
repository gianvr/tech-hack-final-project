# TecHacker - Projeto Final

## Integrantes:
 - Giancarlo Vanoni Ruggiero
 - Tiago Vitorino Seixas

## Diagrama da Arquitetura: 
 - ![Diagrama da arquitetura](/img/tech_hack.svg)

## Pré-requisitos
 - Chave de Acesso 
 - Chave pública SSH para o AWS CodeCommit (4096)
 - Terraform versão 5.26.0
 - AWS CLI
 - VSCode
 - Git

## Tutoriais AWS
 - Criando Chave de Acesso: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey
 - Criando Chave pública SSH:  https://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-ssh-windows.html#setting-up-ssh-windows-keys-windows
 - Instalando AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

## Links para Download
 - Terraform: https://developer.hashicorp.com/terraform/install
 - VSCode: https://code.visualstudio.com/download
 - Git: https://git-scm.com/downloads

## Link Tutorial NAT usado
 - https://docs.aws.amazon.com/vpc/latest/userguide/VPC_NAT_Instance.html

## Iniciando o Projeto
 - Entre na pasta do projeto, e passe as credenciais IAM no AWS CLI

```c
/tech-hack-final-project # export  AWS_ACCESS_KEY_ID="AKXXXXXXXXXXXXXXXXXX"
/tech-hack-final-project # export AWS_SECRET_ACCESS_KEY="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
```

 - Ainda dentro da pasta projeto, dê os comandos para iniciar o backend da estrutura e validar o código

```c
/tech-hack-final-project # terraform init
/tech-hack-final-project # terraform validate
```
 - Uma vez que o código esteja validado, crie o plano para subir a infraestrutura, e o execute

 ```c
/tech-hack-final-project # terraform plan -out nome_do_plano
/tech-hack-final-project # terraform apply "nome_do_plano"
```
### <span style="color:red">Atenção!</span> 
 - Não se esqueça de adicionar o nome do plano no .gitignore caso deseje salvar o projeto em algum lugar após executá-lo

 - Espere alguns minutos enquanto a aws monta a arquitetura

## Testando Jump Server

 - Copie e cole o ip público da instância EC2 guacamole no seu navegador (como é uma conexão http e não https, se o navegador adicionar o 's' padrão no final, apague-o), e digite :8080/guacamole no final

```c
http://X.X.X.X:8080/guacamole
```

 - No caso deste modelo, o usuário e senha do guacamole foram mantidos como guacadmin, mas para uma aplicação real desta arquitetura, recomendamos que, por motivos de segurança, mude ambos

 - Scaneie o QR Code de Autenticação Multi-Fator com um aplicativo - Microsoft Authenticator ou Google Authenticator, por exemplo
 
 - Ao se conectar ao guacamole, é possível acessar as instâncias EC2 (web-server, zabbix, database) que estão na sub-rede privada

 - Caso tente conectar à qualquer uma das instâncias por ssh, não a conexão deve ser bloqueada

## Testando Monitoramento

 - Copie e cole o ip público da instância EC2 zabbix no seu navegador (como é uma conexão http e não https, se o navegador adicionar o 's' padrão no final, apague-o), e digite /zabbix no final

```c
http://X.X.X.X/zabbix
```

- No caso deste modelo, o usuário do zabbix foi mantido como Admin e senha zabbix, mas para uma aplicação real desta arquitetura, recomendamos que, por motivos de segurança, mude ambos

 - Durante o primeiro login do zabbix, se configura o banco de dados, e a senha definida para funcionar nesse projeto é password - caso queira mudar a senha, atualize a senha do arquivo zabbix.sh na pasta zabbix
