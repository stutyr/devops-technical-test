const express = require('express')
const app = express()
const port = 3000

app.get('/', (req, res) => {
  res.send('Hello World!')
})

app.get('/payment/submit', (req, res) => {
  res.send('Thank you for purchasing a product')
})

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`)
})