const mqtt = require('mqtt');

const client = mqtt.connect('mqtt://mqtt-dashboard.com:1883', {
  clientId: `js-backend-${Math.random().toString(16).substr(2, 8)}`
});

const topic = 'sensor/co2';

let currentValue = 400; 
let isIncreasing = true; 

client.on('connect', () => {
  console.log('Бекенд успішно підключено до MQTT-брокера!');
  
  setInterval(() => {
    const step = Math.floor(Math.random() * (300 - 100 + 1)) + 100;
    
    if (isIncreasing) {
      currentValue += step;
    } else {
      currentValue -= step;
    }
    
    if (currentValue >= 5000) {
      currentValue = 5000;
      isIncreasing = false; 
    } else if (currentValue <= 300) {
      currentValue = 300;
      isIncreasing = true; 
    }
    
    client.publish(topic, currentValue.toString(), { qos: 0 }, (err) => {
      if (!err) {
        console.log(`[${new Date().toLocaleTimeString()}] Відправлено CO2: ${currentValue} ppm`);
      } else {
        console.error('Помилка відправки:', err);
      }
    });

  }, 1000);
});

client.on('error', (err) => {
  console.error('Помилка MQTT:', err);
});