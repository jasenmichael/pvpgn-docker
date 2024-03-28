import express from 'express'
import net from 'net'

// import websockify from './websockify.js'
const app = express()

const pvpgnServer = {
  // host: 'server.war2.ru',
  host: '143.244.152.50',
  // host: 'localhost',
  port: 6112,
}

app.use(express.static('../frontend/dist'))

// serve the API at /api
app.get('/api/status', async (req, res) => {
  res.json({ status: await checkStatus() })
})

app.get('/api/login', async (req, res) => {
  const user = "chizzizity"
  const password = "chizzizity"
  const result = await login(user, password)
  console.log('Login result:', result);
  res.json({ result: result || "na" })
})

app.listen(3000, async () => {
  console.log('Server listening on port 3000\r\n#############################\r\n')
  // websockify({
  //   source: `localhost:6110`,
  //   target: 'localhost:6112'
  //   // web
  // })
})

// connect socket client to server
let clientSocket = null
let serverRunning = false
let stringQuery = []

// function helpers
async function connect(cb = null) {
  if (clientSocket !== null){
    return
  }
  clientSocket = await net.createConnection(pvpgnServer, cb)

  clientSocket.on('error', (error) => {
    // connected = false;
    console.log('Error connecting to PVPGN server!', error)
    serverRunning = false
    clientSocket?.end()
    clientSocket = null
  })

  clientSocket.on('data', (data) => {
    console.log(data.toString().replace(/ERROR: Hello/g, 'Hello'), '\r\n')
    serverRunning = true
  })

  clientSocket.on('connect', () => {
    console.log('# Connected to PVPGN server')
  })
  
}

async function checkStatus() {
  const cb = async () => {
    console.log('checking PVPGN server status..')
    serverRunning = true
    clientSocket?.end()
  }
  await connect(cb)
  await new Promise(resolve => clientSocket.on('close', resolve))
  console.log('PVPGN server is', serverRunning ? 'online' : 'offline');
  return serverRunning
}

async function login(username, password, channel = 'War2BNE') {
  clientSocket?.end()
  clientSocket = null
  await connect()

  console.log('Login sent:', username, password, channel)

  sendCmd("\r\n")
  sendCmd(username)
  sendCmd("\r\n")
  sendCmd(password)
  // sendCmd("\r\n")
  // sendCmd("/join " + channel);
  // sendCmd("\r\n");
}

Array.prototype.pushStr = function (str) {
  var n = str.length;
  for (var i = 0; i < n; i++) {
    this.push(str.charCodeAt(i));
  }
}

function sendCmd(msg) {
  console.log('Sending:', msg.trim())
  stringQuery.pushStr(msg + "\r\n")
  // console.log('Sending:', stringQuery);
  if (stringQuery.length > 0) {

    // clientSocket.write(stringQuery)
    clientSocket.write(String.fromCharCode.apply(null, stringQuery));
    // clientSocket.write(Buffer.from(stringQuery));
    stringQuery = [];
  }
}