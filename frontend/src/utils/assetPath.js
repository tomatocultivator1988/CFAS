/**
 * Asset Path Resolver
 * Resolves asset paths for different environments
 */

/**
 * Get the correct asset path for images
 * Works in both development and production
 */
export function getAssetPath(path) {
  // Remove leading slash if present
  const cleanPath = path.startsWith('/') ? path.slice(1) : path
  
  // In development mode, Vite dev server serves from root
  if (import.meta.env.DEV) {
    return `/${cleanPath}`
  }
  
  // In production, use base URL from environment
  const base = import.meta.env.BASE_URL || '/'
  if (base === '/') {
    return `/${cleanPath}`
  }
  
  // Ensure base path ends with slash
  const normalizedBase = base.endsWith('/') ? base : `${base}/`
  return `${normalizedBase}${cleanPath}`
}

/**
 * Get public asset path (for images in public folder)
 * Works for localhost, LAN deployment, and production
 */
export function getPublicAssetPath(filename) {
  // Remove leading slash if present
  const cleanFilename = filename.startsWith('/') ? filename.slice(1) : filename
  
  // In development mode, Vite dev server serves from root
  if (import.meta.env.DEV) {
    return `/${cleanFilename}`
  }
  
  // In production, use base URL from environment
  const base = import.meta.env.BASE_URL || '/'
  if (base === '/') {
    return `/${cleanFilename}`
  }
  
  // Ensure base path ends with slash
  const normalizedBase = base.endsWith('/') ? base : `${base}/`
  return `${normalizedBase}${cleanFilename}`
}
