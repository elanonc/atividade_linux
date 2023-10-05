# PB UFC - Atividade Prática de Linux

Repositório destinado a prática de Linux do PB DevSecOps da Compass UOL.

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

Começando pela parte de configuração da infraestrutura na AWS.

## Criando a instância

Para realizar a criação da instância conforme foi definido, primeiro deve-se configurar a VPC na qual ela será criada.

### Configurando a VPC

1. **Criação de uma VPC**:
   Através do Console de Gerenciamento da AWS, no serviço "VPC", clique em "Criar VPC" e defina um nome e um bloco de CIDR (faixa de endereços IP) para a sua VPC. Após isso, selecione a opção de DNS e DHCP e clique em "Criar VPC".

2. **Criação de uma Sub-rede**:
   Ainda no serviço "VPC", na seção de "Sub-redes", clique em "Criar sub-rede" e selecione a VPC que você acabou de criar. Especifique um bloco de CIDR para a sub-rede e escolha a zona de disponibilidade da AWS, e então, finalize clicando em "Criar sub-rede".

3. **Associação à Tabela de Roteamento**:
   Agora na seção "Tabelas de Roteamento", selecione a tabela de roteamento associada à sua VPC. Na aba "Sub-redes", clique em "Editar associações", selecione a sub-rede que você criou e salve as alterações.

4. **Conexão a um Internet Gateway**:
   Acesse a seção "Internet Gateways" no serviço "VPC", clique em "Criar Internet Gateway" e forneça um nome. Depois disso, selecione o Internet Gateway que você acabou de criar e clique em "Associar VPC" para que seja possível escolher a sua VPC na lista.

## Criando a chave pública

A criação do par de chaves é necessário para ser possível o acesso remoto a sua instância no EC2.

Inicie navegando até o console de gerenciamento de EC2. Após isso, no painel inicial selecione a opção de `Pares de chaves`, e clicar no botão `Criar par de chaves`. Preencha os campos e selecione se deseja .pem ou .x.

### Criando a instância e configurando o Grupo de Segurança

- Acesse o serviço "EC2", clique em "Instâncias" e em "Launch Instances" para iniciar a criação de instâncias.
- Adicione tags para identificar sua instância como achar melhor.
- Escolha "Amazon Linux 2" como sua AMI.
- Selecione "t3.small" como o tipo de instância.
- Configure o tamanho do disco de 16 GB SSD.
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
- Revise as configurações e inicie a sua instância EC2.

### Gerando o Elastic IP e alocando na instância EC2

Pelo Console de Gerenciamento da AWS, no serviço do EC2, a seção "Elastic IPs", clique na opção de gerar um endereço IP elástico. Após gerar o endereço de IP, escolha opção "Associar endereço IP elástico" e selecione a instância criada anteriormente.

**Ao fim dessa parte, teremos configurado a parte da AWS da atividade.**

---

Dando início a parte de Linux da atividade, vamos começar a configuração do NFS.

### Configurando o NFS no servidor

- Se conecte com as instâncias que você criou, abra um terminal SSH para a instância e instale o servidor NFS executando o seguinte comando:

```bash
sudo yum install nfs-utils -y
```

Para configurá-lo, primeiro deve-se definir os diretórios que deseja compartilhar. Para este exemplo, vamos compartilhar um diretório chamado `/mnt/nfs-share`. Se necessário configure as permissões do diretório, para permitir o acesso apropriado.

Abra o arquivo `/etc/exports` para configurar as exportações NFS:

Adicione uma linha no arquivo `/etc/exports` para compartilhar o diretório `/mnt/nfs-share` com permissões de leitura e gravação para todos os hosts na rede. Substitua `<subnet>` pela sua sub-rede, como por exemplo `192.168.1.0/24`:

```
/mnt/shared <subnet>(rw,sync,no_root_squash,no_all_squash)
```

Após concluir, salve e saia do editor de texto.

Agora, você precisa iniciar o serviço NFS e habilitá-lo para que ele seja iniciado automaticamente após a reinicialização da instância:

```bash
sudo systemctl start nfs
sudo systemctl enable nfs
```

Para verificar se o NFS está funcionando corretamente, você pode usar o seguinte comando:

```bash
sudo systemctl status nfs
```

Se tudo estiver configurado corretamente, você deve ver o status "active (running)".

### Configurar NFS no cliente

Conecte-se a outra instância criada para o cliente. Nessa máquina será preciso criar um diretório onde o compartilhamento NFS será montado, como por exemplo: `/mnt/nfs`

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

     timestamp=$(date '+%Y-%m-%d %H:%M:%S')
     service_name="Apache"
     service_status=$(systemctl is-active httpd)

     if [ "$service_status" = "active" ]; then
       status_message="Online"
       output_file="/nfs/seu_nome/service_online.txt"
     else
       status_message="Offline"
       output_file="/nfs/seu_nome/service_offline.txt"
     fi

     echo "$timestamp $service_name $status_message" > "$output_file"
     ```

Para tornar o Script Executável, deve-se dar permissão de execução ao script:

```
chmod +x is_apache_online.sh
```

Abra o cronjob para edição `crontab -e`. Adicione a seguinte linha para executar o script a cada 5 minutos: `*/5 * * * * /caminho/completo/do/script/is_apache_online.sh`. Salve e saia do editor.

Agora, o script `is_apache_online.sh` será executado a cada 5 minutos, verificando o status do Apache e gravando os resultados em arquivos dentro do diretório NFS que você criou.
