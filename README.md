## Building Apache Kafka Connectors

Building connectors for Apache Kafka is hard. Chances are that you just read the previous sentence, and you subconsciously nooded with your head. The reason this happens is that Kafka Connect, which is the runtime platform behind the executing connectors, is way over-engineered. There is a clear lack of a proper documentation that teaches how the development framework works, how it connects with the runtime, and which best practices you must follow.

For situations like this, your best bet is to get hold of an existing code and try to do the same, hoping your own connector will be written the best way possible. By all means, this is an excellent strategy. But most of the time, it is hard to understand the code, as the connector you took as an example might have more code focused on solving the technical problem that the connector is aiming to solve than only the code part related to building custom connectors.

This is the reason this project exists. This is a minimalistic repository that contains a source connector, whose focus is to show how the development framework from Kafka Connect works. From this repository, you can easily derive your own connector and write only the code that matter for your technical use case.

### Requirements

* [Docker](https://www.docker.com/get-started)
* [Java 17+](https://openjdk.org/install)
* [Maven 3.8.6+](https://maven.apache.org/download.cgi)

## 1️⃣ Building the connector

The first thing you need to do to use this connector is to build it. To do that, you need to install the following dependencies:

- [Java 11+](https://openjdk.java.net)
- [Apache Maven](https://maven.apache.org)

After installing these dependencies, execute the following command:

```bash
mvn clean package
```

💡 A file named `target/my-first-kafka-connector-1.0.jar` will be created. This is your connector for Kafka Connect.

## 2️⃣ Starting the local environment

With the connector properly built, you need to have a local environment to test it. This project includes a Docker Compose file that can spin up container instances for Apache Kafka and Kafka Connect. To do that, you need to install the following dependencies:

- [Docker](https://www.docker.com/get-started)

Start the containers using the following command:

```bash
docker compose up -d
```

Wait until the containers `zookeeper`, `kafka`, `schema-registry`, and `connect` are started and healthy.

## 3️⃣ Deploying and testing the connector

Nothing is actually happening since the connector hasn't been deployed. Once you deploy the connector, it will start generating sample data from an artificial source and write this data off into three Kafka topics.

To deploy the connector, use the following command:

```bash
curl -X POST -H "Content-Type:application/json" -d @examples/my-first-kafka-connector.json http://localhost:8083/connectors
```

After deploying the connector, you can check if it is producing data to Kafka topics by running the following commands:

```bash
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic source-1 --from-beginning
```

```bash
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic source-2 --from-beginning
```

```bash
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic source-3 --from-beginning
```

All three topics should have sample data continuously generated for them.

## 4️⃣ Debugging the connector

This is actually an optional step, but if you wish to debug the connector code to learn its behavior by watching the code executing line by line, you can do so by using remote debugging. The Kafka Connect container created in the Docker Compose file was changed to rebind the port 8888 to enable support for [JDWP](https://en.wikipedia.org/wiki/Java_Debug_Wire_Protocol). The instructions below assume that you are using [Visual Studio Code](https://code.visualstudio.com) for debugging.

To leverage this support, create a file named `.vscode/launch.json` with the following content:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug Connector",
            "type": "java",
            "request": "attach",
            "hostName": "localhost",
            "port": 8888
        }
    ]
}
```

Then, set one or multiple breakpoints throughout the code. Once this is done, you can launch a debugging session to attach the IDE to the container.

## 5️⃣ Undeploy the connector

Use the following command to undeploy the connector from Kafka Connect:

```bash
curl -X DELETE http://localhost:8083/connectors/my-first-kafka-connector
```

## 6️⃣ Stopping the local environment

Stop the containers using the following command:

```bash
docker compose down
```

## 7️⃣ Deploying into AWS

Once you have played with the connector locally, you can also deploy the connector in the cloud. This project contains the code necessary for you to automatically deploy this connector in AWS using Terraform. To deploy the connector in AWS, you will need:

- [Terraform 1.3.0+](https://www.terraform.io/downloads)
- [AWS Account](https://aws.amazon.com/resources/create-account)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

You will also need to have the credentials from your AWS account properly configured in your system. You can do this by running the command `aws configure` using the AWS CLI. More information on how to do this [here](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html).

Follow these steps to execute the deployment.

1. Go to the `deploy-aws` folder.

```bash
cd deploy-aws
```

2. Initialize the Terraform plugins.

```bash
terraform init
```

3. Execute the deployment.

```bash
terraform apply -auto-approve
```

It may take several minutes for this deployment to finish, depending on your network speed, AWS region selected, and other factors. On average, you can expect something like 30 minutes or more. Please note that the Terraform code will create several resources in your AWS account. For this reason, be sure to execute the ninth step to destroy these resources, so you don't end up with an unexpected bill.

Once the deployment completes, you should see the following output:

```bash
Outputs:

execute_this_to_access_the_bastion_host = "ssh ec2-user@<PUBLIC_IP> -i cert.pem"
```

4. SSH into the bastion host.

```bash
ssh ec2-user@<PUBLIC_IP> -i cert.pem
```

💡 The following steps assume you are connected to the bastion host.

5. List the endpoints stored in the `/etc/hosts` file.

```bash
more /etc/hosts
```

6. Copy one of the endpoints mapped to the item `bootstrap-server`.

7. Check if the connector is writing data to the topics.

```bash
kafka-console-consumer.sh --bootstrap-server <ENDPOINT_COPIED_FROM_HOSTS_FILE> --topic source-1 --from-beginning
```

```bash
kafka-console-consumer.sh --bootstrap-server <ENDPOINT_COPIED_FROM_HOSTS_FILE> --topic source-2 --from-beginning
```

```bash
kafka-console-consumer.sh --bootstrap-server <ENDPOINT_COPIED_FROM_HOSTS_FILE> --topic source-3 --from-beginning
```

8. Exit the connection with the bastion host.

```bash
exit
```

9. Destroy all the resources created by Terraform.

```bash
terraform destroy -auto-approve
```

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This project is licensed under the MIT-0 License. See the [LICENSE](./LICENSE) file.
