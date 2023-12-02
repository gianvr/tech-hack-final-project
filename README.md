# TecHacker - Projeto Final

## Integrantes:
 - Giancarlo Vanoni Ruggiero
 - Tiago Vitorino Seixas

## Diagrama da Arquitetura: 
![Diagrama da arquitetura](/img/tech_hack.svg)

## Pré-requisitos
 - Chave de Acesso 
 - Chave pública SSH para o AWS CodeCommit (4096)
 - Terraform versão 5.26.0
 - AWS CLI
 - VSCode
 - Git

## Tutoriais AWS
 - Criando Chave de Acesso: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey
 - Criando Chave pública SSH (Windows):  https://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-ssh-windows.html#setting-up-ssh-windows-keys-windows
 - Criando Chave pública SSH (Linux, macOS, Unix): https://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-ssh-unixes.html
 - Instalando AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

## Links para Download
 - Terraform: https://developer.hashicorp.com/terraform/install
 - VSCode: https://code.visualstudio.com/download

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

 - Não feche o terminal após dar o apply, pois a saída do terminal será usada

## Testando Jump Server

 - Copie e cole o ip público da instância EC2 guacamole no seu navegador (como é uma conexão http e não https, se o navegador adicionar o 's' padrão no final, apague-o), e digite :8080/guacamole no final

```c
http://X.X.X.X:8080/guacamole
```

 - No caso deste modelo, o usuário e senha do guacamole foram mantidos como guacadmin, mas para uma aplicação real desta arquitetura, recomendamos que, por motivos de segurança, mude ambos

 - Scaneie o QR Code de Autenticação Multi-Fator com um aplicativo - Microsoft Authenticator ou Google Authenticator, por exemplo
 
 - Ao se conectar ao guacamole, é possível acessar as instâncias EC2 (web-server, zabbix, database) que estão na sub-rede privada

 - Caso tente conectar à qualquer uma das instâncias por ssh que não a guacamole, a conexão deve ser bloqueada

## Testando Monitoramento

### Conectando ao Zabbix

 - Copie e cole o ip público da instância EC2 zabbix no seu navegador (como é uma conexão http e não https, se o navegador adicionar o 's' padrão no final, apague-o), e digite /zabbix no final

```c
http://X.X.X.X/zabbix
```

 - No caso deste modelo, o usuário do zabbix foi mantido como Admin e senha zabbix, mas para uma aplicação real desta arquitetura, recomendamos que, por motivos de segurança, mude ambos

 - Durante o primeiro login do zabbix, se configura o banco de dados, e a senha definida para funcionar nesse projeto é password - caso queira mudar a senha, atualize a senha do arquivo zabbix.sh na pasta zabbix

 ### Configurando Hosts

  - No Dashboard do Zabbix, selecione Hosts > Create Host

  - Na saída do terminal, após o terraform apply,  tem o hostname e o IP dos hosts que devem ser configurados

  - Para configurar o IP, selecione Add > Zabbix Agent, e o grupo pode ser qualquer um (não interfere em nada, mas é obrigatório)

  - Por fim, basta selecionar o template, clicando no botão Select > Template/Operating Systems > Linux by Zabbix Agent

  - Repita esse processo para as 3 instâncias

## Testando CI/CD 

  - Repita as etapas de teste de Jump Server e de Monitoramento anteriores, mas dessa vez usando as instâncias do ambiente de teste (testing_guacamole, testing_web_server, etc), lembrando que os hostnames são os mesmos, porém os IPs mudam

  - Considerando que você já tenha feito a chave SSH para AWS Code Commit, acesse o repositório no dashboard da AWS, clique no botão Clone URL, e selecione a opção Clone SSH

  - No seu terminal, vá para o local onde quer armazenar o seu repositório local, e rode o comando de clonar do git com o link clonado anteriormente

```c
/exemplo_dir # git clone seu_link
```

  - Copie para esse repositório vazio o arquivo appspec.yml na pasta cicd do projeto, e adicione o conteúdo que quiser que seja adicionado à instância web_server. No caso deste tutorial, iremos criar um arquivo de texto simples, e o nome do repositório é Repository

```c
/exemplo_dir # cd Repository
/exemplo_dir/Repository # cp /tech-hack-final-project/cicd/appspec.yml appspec.yml
/exemplo_dir/Repository # touch exemplo.txt
```

 - Dê add, commit e push nas suas alterações

```c
/exemplo_dir/Repository # git add -A
/exemplo_dir/Repository # git commit -m "mensagem de commit"
/exemplo_dir/Repository # git push
```

 - No Dashboard da AWS, em Code Pipeline, selecione a pipeline chamada Pipeline, e lance as alterações

 - Após os deploys do Source e do Testing serem realizados com sucesso, cheque na instância testing_web_server se foi criado o arquivo exemplo.txt na pasta /tmp

```c
/home/ubuntu # cd /tmp
/tmp # ls
... outros arquivos ...
exemplo.txt
... outros arquivos ...
```

 - Uma vez confirmado que o deploy funcionou, dê permissão para o deploy no ambiente de produção no dasboard
 - Quando o deploy terminar, confira na instância web_server se foi criado o arquivo exemplo.txt na pasta /tmp, como anteriormente

## Destruindo Recursos

 - Após finalizar os testes da arquitetura, vá para a pasta do projeto na sua máquina local e destrua os recursos pelo terraform

```c
/tech-hack-final-project # terraform destroy
```

