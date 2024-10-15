import { SELF } from 'cloudflare:test'
import { describe, it, expect } from 'vitest'

describe('Test worker', () => {
  it('responds with forbidden for malformed jwt token', async () => {
    const accessToken = 'asdasd'
    const response = await SELF.fetch('https://example.com', {
      headers: { Authorization: 'Bearer ' + accessToken },
    })
    expect(response.status).toBe(403)
  })

  it('responds with forbidden for missing authorization header', async () => {
    const response = await SELF.fetch('https://example.com')
    expect(response.status).toBe(403)
  })

  it('responds with forbidden for invalid jwt token', async () => {
    const accessToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.e30.01w1j74PhEDuD4CdiZ6Bhw9ZjZRTZE0d3I_LcfzqSq0'
    const response = await SELF.fetch('https://example.com', {
      headers: { Authorization: 'Bearer ' + accessToken },
    })
    expect(response.status).toBe(403)
  })

  it('responds with OK for valid jwt token', async () => {
    const accessToken = import.meta.env.VITE_LOVESMENOT_JWT_TOKEN
    const response = await SELF.fetch('https://example.com', {
      headers: { Authorization: 'Bearer ' + accessToken },
    })
    expect(response.status).toBe(200)
  })
})
