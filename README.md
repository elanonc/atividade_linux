# PB UFC - Atividade Prática de Linux

Autor: Elano Nunes Caitano

# Requisitos AWS

- Gerar uma chave pública para acesso ao ambiente;
- Criar 1 instância EC2 com o sistema operacional Amazon Linux 2 (Família t3.small, 16 GB SSD);
- Gerar 1 elastic IP e anexar à instância EC2;
- Liberar as portas de comunicação para acesso público: (22/TCP, 111/TCP e UDP, 2049/TCP/UDP, 80/TCP, 443/TCP).

# Requisitos Linux

- Configurar o NFS entregue;
- Criar um diretorio dentro do filesystem do NFS com seu nome;
- Subir um apache no servidor - o apache deve estar online e rodando;
- Criar um script que valide se o serviço esta online e envie o resultado da validação para o seu diretorio no nfs;
- O script deve conter - Data HORA + nome do serviço + Status + mensagem personalizada de ONLINE ou offline;
- O script deve gerar 2 arquivos de saida: 1 para o serviço online e 1 para o serviço OFFLINE;
- Preparar a execução automatizada do script a cada 5 minutos.
- Fazer o versionamento da atividade;
- Fazer a documentação explicando o processo de instalação do Linux.

---

# Instruções de execução

As instruções que virão a seguir tem como objetivo descrever as etapas da configuração de todos os requisitos listados anteriormente. Começando pela parte de configuração da infraestrutura na AWS.

## Criando a instância

Para realizar a criação da instância conforme foi definido, primeiro deve-se configurar a VPC na qual a instância será criada posteriormente.

### Configurando a VPC

1. **Criação de uma VPC**:
   Através do Console de Gerenciamento da AWS, no serviço "VPC", clique em "Criar VPC" e defina um nome e um bloco de CIDR (faixa de endereços IP) para a sua VPC. Após isso, selecione a opção de DNS e DHCP e clique em "Criar VPC".

2. **Criação de uma Sub-rede**:
   Ainda no serviço "VPC", na seção de "Sub-redes", clique em "Criar sub-rede" e selecione a VPC que você acabou de criar. Especifique um bloco de CIDR para a sub-rede e escolha a zona de disponibilidade da AWS, e então, finalize clicando em "Criar sub-rede".

3. **Associação à Tabela de Roteamento**:
   Agora na seção "Tabelas de Roteamento", selecione a tabela de roteamento associada à sua VPC. Na aba "Sub-redes", clique em "Editar associações", selecione a sub-rede que você criou e salve as alterações.

4. **Conexão a um Internet Gateway**:
   Acesse a seção "Internet Gateways" no serviço "VPC", clique em "Criar Internet Gateway" e forneça um nome. Depois disso, selecione o Internet Gateway que você acabou de criar e clique em "Associar VPC" para que seja possível escolher a sua VPC na lista.

### Criando a instância e configurando o Grupo de Segurança

- Acesse o serviço "EC2", clique em "Instâncias" e em "Executar Instâncias" para iniciar a criação de instâncias EC2.
- Adicione tags para identificar sua instância como achar melhor.
- Escolha "Amazon Linux 2" como sua AMI.
- Selecione "t3.small" como o tipo de instância.
- Configure o tamanho do disco de 16 GB SSD.
- Crie a chave de segurança que vocêusará para se conectar a sua máquina:
  - Ao lado do painel de seleção de chaves, terá a opção de criar um novo par de chaves de segurança.
  - Adicione um nome e selecione a extensão do par de chaves entre .pem ou.ppk.
- Configurar grupo de segurança:
  - Clique em "Criar novo grupo de segurança".
  - Forneça um nome e uma descrição para o grupo de segurança.
  - Na seção "Regras de entrada", clique em "Adicionar regra de entrada".
    - Adicione as seguintes regras de entrada para permitir acesso público nas portas especificadas:
      - SSH (Porta 22/TCP)
      - RPC Port 111 (Portas 111/TCP e 111/UDP)
      - NFS Port 2049 (Portas 2049/TCP e 2049/UDP)
      - HTTP (Porta 80/TCP)
      - HTTPS (Porta 443/TCP)
    - Defina a fonte para "0.0.0.0/0" para permitir o acesso de qualquer lugar.
    - Ao fim, a configuração do seu grupo de segurança será semelhante a essa:
      ![image](https://drive.google.com/uc?export=view&id=1DVKZdFv4uHFW_mgtf7626nHpRz0LeK7h)
- Revise as configurações e inicie a sua instância EC2.

### Gerando o Elastic IP e alocando na instância EC2

Pelo Console de Gerenciamento da AWS, no serviço do EC2, a seção "Elastic IPs", clique na opção de gerar um endereço IP elástico. Após gerar o endereço de IP, escolha opção "Associar endereço IP elástico" e selecione a instância criada anteriormente.

**Ao fim dessa parte, a configuração da infaestrutura na AWS da atividade terá sido realizada.**

---

Dando início a parte de Linux da atividade, vamos começar pela configuração do NFS.

### Configurando o NFS no servidor

No console de gerenciamento da AWS, ao selecionar a instância criada anteriormente, é possível conectar-se a ela dentro da própria AWS clicando no botão de conectar e depois clicando no botão de conectar que aparecerá no outro painel. Outra forma, é utilizar o par de chaves criado no processo de criação da instância, de forma que se conecte a sua máquina pessoal.

![image](https://drive.google.com/uc?export=view&id=169L49vxtwYBlQwFmLEaYjd10iafw1aAa)

Após ter se conectado com a instância, instale o servidor NFS executando o seguinte comando:

```bash
sudo yum install nfs-utils -y
```

Para configurá-lo, primeiro deve-se definir os diretórios que deseja compartilhar. Para este exemplo, vamos compartilhar um diretório chamado `/mnt/nfs_share`. Se necessário configure as permissões do diretório, para permitir o acesso apropriado.

Abra o arquivo `/etc/exports` para configurar as exportações NFS:

```bash
sudo vim /etc/exports
```

Adicione uma linha no arquivo `/etc/exports` para compartilhar o diretório `/mnt/nfs_share` com permissões de leitura e gravação para todos os hosts na rede. Substitua `<ipPublico>` pelo ip publico da máquina do cliente que deseja fazer a conexão com o NFS, ou pela subnet da VPC, mas também há opção de colocar '\*' para que todos os ip's possam acessar a pasta compartilhada.

```
/mnt/nfs_share <ipPublico>(rw,sync,no_root_squash,no_all_squash)
```

- rw: Leitura e escrita permitidas para clientes.
- sync: Operações de gravação executadas de forma síncrona.
- no_root_squash: O root do cliente terá as mesmas permissões do root do servidor NFS.
- no_all_squash: Os usuários do cliente teráo as mesmas permissões do servidor NFS.

Após concluir, salve e saia do editor de texto.

Agora, será preciso iniciar o serviço NFS e habilitá-lo para que ele seja iniciado automaticamente após a reinicialização da instância:

```bash
sudo systemctl start nfs
sudo systemctl enable nfs
```

Para verificar se o NFS está funcionando corretamente, use o seguinte comando:

```bash
sudo systemctl status nfs
```

Se tudo estiver configurado corretamente, será possível ver o status "active (running)".

![image](https://drive.google.com/uc?export=view&id=14PO3udERMdAL14u3Ply9-HgDkRbd3spm)

Para obter mais segurança e controle sobre o tráfego de rede, pode-se optar pela instalação de um firewall. Nesse caso, eu optei pela instalação do `firewalld`.

```bash
sudo yum install firewalld
```

Após a instalação, você pode habilitar e iniciar o serviço:

```bash
sudo systemctl enable firewalld
sudo systemctl start firewalld
```

Será necessário permitir as portas usadas pelo NFS, que incluem as portas 111 e 2049 (NFS). Para fazer isso, execute os seguintes comandos:

```bash
sudo firewall-cmd --add-service=nfs --permanent
sudo firewall-cmd --add-service=rpc-bind --permanent
sudo firewall-cmd --reload
```

Dessa forma, será possível manter a conexão com o cliente quando ela for realizada.

### Configurar NFS no cliente

Conecte-se a outra máquina, que será a máquina do cliente. Uma opção, é criar outra instância EC2 na AWS e usá-la como máquina do cliente.

![image](https://drive.google.com/uc?export=view&id=1_GahRbOrs_WhMEfsDRS1LrJmqzHYUKn4)

Conecte-se a essa máquina, e crie um diretório onde o compartilhamento NFS será montado, como por exemplo: `/mnt/nfs`

```bash
sudo mkdir -p /mnt/nfs
```

Tendo feito isso, será possível montar o compartilhamento NFS do servidor. Use o comando `mount` com o endereço IP do servidor e o caminho do compartilhamento que você configurou no servidor. Por exemplo:

```bash
sudo mount -t nfs <endereço_IP_do_servidor_NFS>:<caminho_do_compartilhamento_no_servidor> /mnt/nfs
```

Para verificar se o compartilhamento NFS foi montado com sucesso, basta listar o conteúdo do diretório `/mnt/nfs`.

Agora que o NFS está devidamente configurado tanto para o cliente como para o servidor, vamos seguir na etapa de configuração do servidor Apache.

### Configurar e Iniciar o Apache:

Instale o servidor Apache com o seguinte comando:

```
sudo yum install httpd
```

Inicie o Apache e configure-o para iniciar automaticamente:

```
sudo systemctl start httpd
sudo systemctl enable httpd
```

Agora o servidor Apache já está online. Para verificar o status dele, basta executar o comando: `sudo systemctl status httpd`.

### Configurar o Script

Só resta configurar o script para a validação se o servidor está online.

Crie um script em bash (por exemplo, `is_apache_online.sh`) usando um editor de texto:

```bash
nano is_apache_online.sh
```

Adicione o seguinte conteúdo ao script para verificar o status do Apache e gravar os resultados em arquivos:

```bash
    #!/bin/bash

    #Script para obter o status do serviço apache

    SERVICO=httpd

    STATUS=$(systemctl is-active $SERVICO)

    MENSAGEM1="O $SERVICO está ONLINE"
    MENSAGEM2="O $SERVICO está offline"

    export LC_TIME=pt_BR.utf8

    DATA=$(date '+%d de %B de %Y')
    HORA=$(date '+%H:%M:%S')

    if [ $STATUS == "active" ]; then
        echo "$DATA - $HORA" >> /mnt/nfs_share/elanonunes/online.txt
        echo "Status=$STATUS"  >> /mnt/nfs_share/elanonunes/online.txt
        echo "$MENSAGEM1" >> /mnt/nfs_share/elanonunes/online.txt
        echo "---------------------------------" >> /mnt/nfs_share/elanonunes/online.txt
    else
        echo "$DATA - $HORA" >> /mnt/nfs_share/elanonunes/offline.txt
        echo "Status=$STATUS" >> /mnt/nfs_share/elanonunes/offline.txt
        echo "$MENSAGEM2" >> /mnt/nfs_share/elanonunes/offline.txt
        echo "---------------------------------" >> /mnt/nfs_share/elanonunes/offline.txt
    fi
```

Para tornar o Script Executável, deve-se dar permissão de execução ao script:

```
chmod +x is_apache_online.sh
```

Abra o cronjob para edição `crontab -e`. Adicione a seguinte linha para executar o script a cada 5 minutos: `*/5 * * * * /caminho/completo/do/script/is_apache_online.sh`. Salve e saia do editor.

Agora, o script `is_apache_online.sh` será executado a cada 5 minutos, verificando o status do Apache e gravando os resultados em arquivos dentro do diretório NFS que você criou.
