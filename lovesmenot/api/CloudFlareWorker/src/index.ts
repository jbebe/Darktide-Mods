import { createCryptoKey, getToken, verify } from './utils'

export default {
  async fetch(request, env, _): Promise<Response> {
    const errorResponse = new Response(null, { status: 403 })
    const token = getToken(request)
    if (!token) return errorResponse
    const publicKey = await createCryptoKey(env.LOVESMENOT_JWT_PUBLIC_KEY)
    const isSuccess = await verify(token, publicKey)
    if (!isSuccess) {
      return errorResponse
    }
    return fetch(request as unknown as Request)
  },
} satisfies ExportedHandler<Env>
