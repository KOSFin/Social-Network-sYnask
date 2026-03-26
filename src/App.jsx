import { useState } from 'react'
import { formatCounter } from './lib/formatCounter'
import './App.css'

function App() {
  const [count, setCount] = useState(0)

  return (
    <main>
      <h1>Synask Frontend</h1>
      <p>Deployment profile: {import.meta.env.MODE}</p>
      <button onClick={() => setCount((value) => value + 1)}>{formatCounter(count)}</button>
    </main>
  )
}

export default App
