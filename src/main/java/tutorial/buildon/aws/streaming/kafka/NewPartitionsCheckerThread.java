package tutorial.buildon.aws.streaming.kafka;

import java.util.Arrays;
import java.util.List;
import java.util.Random;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.apache.kafka.connect.connector.ConnectorContext;

public class NewPartitionsCheckerThread extends Thread {

    private final Logger log = LoggerFactory.getLogger(NewPartitionsCheckerThread.class);
    private final CountDownLatch shutdownLatch = new CountDownLatch(1);
    private final Random random = new Random(System.currentTimeMillis());

    private ConnectorContext context;
    private int monitorThreadTimeout;

    public NewPartitionsCheckerThread(ConnectorContext context,
        int monitorThreadTimeout) {
        this.context = context;
        this.monitorThreadTimeout = monitorThreadTimeout;
    }

    @Override
    public void run() {
        log.info("Starting thread to monitor topic regex.");
        while (shutdownLatch.getCount() > 0) {
            try {
                // The condition below is just an example of what should be an more elaborated
                // criteria to be done in the source system using the parameters provided.
                if (random.nextInt(monitorThreadTimeout) > (monitorThreadTimeout / 2)) {
                    log.info("Changes detected in the source. Requesting reconfiguration...");
                    if (context != null) {
                        context.requestTaskReconfiguration();
                    }
                }
                boolean shuttingDown = shutdownLatch.await(monitorThreadTimeout, TimeUnit.MILLISECONDS);
                if (shuttingDown) {
                    return;
                }
            } catch (InterruptedException ie) {
                log.error("Unexpected InterruptedException, ignoring: ", ie);
            }
        }
    }

    public synchronized List<String> getCurrentSources() {
        return Arrays.asList("source-1", "source-2", "source-3");
    }

    public void shutdown() {
        log.info("Shutting down the monitoring thread.");
        shutdownLatch.countDown();
    }

}
