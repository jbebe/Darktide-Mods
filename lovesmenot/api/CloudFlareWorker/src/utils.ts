export function getToken(request: Request<unknown, IncomingRequestCfProperties<unknown>>) {
  const header = request.headers.get('Authorization')
  const token = header?.substring('Bearer '.length)
  if (!token) return null

  return token
}

export async function createCryptoKey(rawKey: string) {
  const arrayBuffer = base64StringToArrayBuffer(rawKey)
  const key = await crypto.subtle.importKey(
    // Key exported as SubjectPublicKeyInfo
    'spki',
    arrayBuffer,
    // Key has PKCS1 format
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    // We only need the key for verification
    ['verify']
  )
  return key
}

function decodePayload<T = any>(raw: string): T | undefined {
  try {
    const bytes = Array.from(atob(raw), char => char.charCodeAt(0))
    const decodedString = new TextDecoder('utf-8').decode(new Uint8Array(bytes))
    return JSON.parse(decodedString)
  } catch {
    return
  }
}

function stringToBytes(byteStr: string): Uint8Array {
  let bytes = new Uint8Array(byteStr.length)
  for (let i = 0; i < byteStr.length; i++) {
    bytes[i] = byteStr.charCodeAt(i)
  }
  return bytes
}

function base64StringToArrayBuffer(b64str: string): ArrayBuffer {
  return stringToBytes(atob(b64str)).buffer
}

function base64UrlToArrayBuffer(b64url: string): ArrayBuffer {
  return base64StringToArrayBuffer(b64url.replace(/-/g, '+').replace(/_/g, '/').replace(/\s/g, ''))
}

export async function verify(token: string, key: CryptoKey): Promise<boolean> {
  // Validate input
  if (typeof token !== 'string') return false
  if (typeof key !== 'object') return false
  const tokenParts = token.split('.')
  if (tokenParts.length !== 3) return false

  // Set algorithm
  const algorithmName = 'RS256'
  const algorithm: SubtleCryptoImportKeyAlgorithm = {
    name: 'RSASSA-PKCS1-v1_5',
    hash: { name: 'SHA-256' },
  }

  // Validate signature
  const header = decodePayload<{ typ?: string; alg?: string }>(
    token.split('.')[0].replace(/-/g, '+').replace(/_/g, '/')
  )
  if (header?.alg !== algorithmName) return false
  return await crypto.subtle.verify(
    algorithm,
    key,
    base64UrlToArrayBuffer(tokenParts[2]),
    stringToBytes(`${tokenParts[0]}.${tokenParts[1]}`)
  )
}
