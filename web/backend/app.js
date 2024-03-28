import express from 'express'
const app = express()

// server the static files at /
app.use(express.static('../frontend/dist'))

app.listen(3000, () => {
  console.log('Server listening on port 3000!')
})
