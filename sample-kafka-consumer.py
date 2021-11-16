from kafka import KafkaConsumer
import ssl
import json

context = ssl.create_default_context()
context.options &= ssl.OP_NO_TLSv1
context.options &= ssl.OP_NO_TLSv1_1
endpoint="<YOUR.EVENTHUBS.CONNECTION.STRING>"
KAFKA_HOST = "<NAMESPACENAME>.servicebus.windows.net:9093"

consumer = KafkaConsumer('<EVENTHUBNAME>',group_id =None,auto_offset_reset='latest',bootstrap_servers=KAFKA_HOST,security_protocol='SASL_SSL',sasl_mechanism='PLAIN',sasl_plain_username='$ConnectionString',sasl_plain_password=endpoint,api_version = None,ssl_context = context)

for message in consumer:
    print(message.value)
    msg = message.value
    print(json.loads(msg.decode('utf-8')))