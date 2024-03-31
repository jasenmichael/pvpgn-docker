import express from 'express'
import net from 'net'

// import websockify from './websockify.js'
const app = express()

const pvpgnServer = {
  // host: 'server.war2.ru',
  // host: '143.244.152.50',
  host: 'localhost',
  port: 6112,
}

app.use(express.static('../frontend/dist'))

// serve the API at /api
app.get('/api/status', async (req, res) => {
  res.json({ status: await checkStatus() })
})

app.page.on('request', request => {
  console.log(request.url());
});('/api/login', async (req, res) => {
  const user = "yoyoyoyoyo"
  const password = "yoyoyoyoyo"
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
let message = null
let token = null

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
    message = data.toString()
      .replace("ERROR: Hello", 'Hello')
      .replace("Enter your account name and password.", '')
      .replace("Sorry, there is no guest account.", '')
      .replace("Username: ", '')
      .replace("Password: ", '')
      .replace("Joining channel: \"Chat\"", '')
    
    console.log(message)
    message = null
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

async function login(username, password, channel = 'War2BNE-1') {
  if (!clientSocket) {
    await connect()
    console.log('Login sent:', username, password, channel)
    sendCmd("\r\n")
    sendCmd(username)
    sendCmd(password)
    sendCmd("/join " + channel)
    sendCmd("\r\n")
    sendCmd("\r\n")
    sendCmd("\r\n")
    // sendCmd("/stats " + username + " WAR2" )
    // sendCmd("/help" )
    await new Promise(resolve => setTimeout(resolve, 500))

    token = "verrrrrrry-secure-token"
  } else {
    console.log('Already connected to PVPGN server')

  }
  return token
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
  if (stringQuery.length > 0) {

    // clientSocket.write(String.fromCharCode.apply(null, stringQuery));
    clientSocket.write(Buffer.from(stringQuery))
    stringQuery = [];
  }
}