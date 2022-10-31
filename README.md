## Building Apache Kafka Connectors

Building connectors for Apache Kafka is hard. Chances are that you just read the previous sentence, and you subconsciously nooded with your head. The reason this happens is that Kafka Connect, which is the runtime platform behind the executing connectors, is way over-engineered. There is a clear lack of a proper documentation that teaches how the development framework works, how it connects with the runtime, and which best practices you must follow.

For situations like this, your best bet is to get hold of an existing code and try to do the same, hoping your own connector will be written the best way possible. By all means, this is an excellent strategy. But most of the time, it is hard to understand the code as the connector you took as an example might have more code solving the technical problem that connector is aiming to solve than actually — explicitly show you how to develop your own connector.

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

A file named `target/my-first-kafka-connector-1.0.jar` will be created. This is your connector for Kafka Connect.

## 2️⃣ Starting the local environment

With the connector properly built, you need to have a local environment to test it. This project includes a Docker Compose file that can spin up container instances for Apache Kafka and Kafka Connect. To do that, you need to install the following dependencies:

- [Docker](https://www.docker.com/get-started)

Start the container using the following command:

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

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the [LICENSE](./LICENSE) file.
