import { fireEvent, render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'

import App from './App'

describe('App', () => {
  it('increments counter on click', () => {
    render(<App />)

    const button = screen.getByRole('button', { name: /Clicks:/i })
    fireEvent.click(button)

    expect(button).toHaveTextContent('Clicks: 1')
  })
})
