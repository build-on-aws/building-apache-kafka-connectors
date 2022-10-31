package tutorial.buildon.aws.streaming.kafka;

import java.util.HashMap;
import java.util.Map;

import org.apache.kafka.connect.connector.Task;
import org.apache.kafka.connect.errors.ConnectException;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

public class MyFirstConnectorTest {

    @Test
    public void connectorVersionShouldMatch() {
        String version = PropertiesUtil.getConnectorVersion();
        assertEquals(version, new MyFirstKafkaConnector().version());
    }

    @Test
    public void checkClassTask() {
        Class<? extends Task> taskClass = new MyFirstKafkaConnector().taskClass();
        assertEquals(MyFirstKafkaConnectorTask.class, taskClass);
    }

    @Test
    public void checkMissingRequiredParams() {
        assertThrows(ConnectException.class, () -> {
            Map<String, String> props = new HashMap<>();
            new MyFirstKafkaConnector().validate(props);
        });
    }

}
