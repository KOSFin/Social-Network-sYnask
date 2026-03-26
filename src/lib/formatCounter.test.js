import { describe, expect, it } from 'vitest'

import { formatCounter } from './formatCounter'

describe('formatCounter', () => {
  it('formats counter value with label', () => {
    expect(formatCounter(7)).toBe('Clicks: 7')
  })
})
