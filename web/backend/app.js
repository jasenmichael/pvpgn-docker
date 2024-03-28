import express from 'express'
const app = express()

// server the static files at /
app.use(express.static('../frontend/dist'))

// serve the API at /api
app.get('/api', (req, res) => {
  res.send('Hello World!!')
})

app.listen(3000, () => {
  console.log('Server listening on port 3000!')
})
