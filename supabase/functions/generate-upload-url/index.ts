import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Verify auth
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    )

    const { data: { user } } = await supabaseClient.auth.getUser()
    if (!user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const { path, contentType } = await req.json()

    // Authenticate with Backblaze B2
    const authResponse = await fetch(
      'https://api.backblazeb2.com/b2api/v2/b2_authorize_account',
      {
        headers: {
          Authorization: `Basic ${btoa(
            `${Deno.env.get('BACKBLAZE_KEY_ID')}:${Deno.env.get('BACKBLAZE_APPLICATION_KEY')}`
          )}`,
        },
      }
    )
    const auth = await authResponse.json()

    if (!auth.authorizationToken) {
      throw new Error('Failed to authenticate with Backblaze')
    }

    // Get upload URL
    const uploadUrlResponse = await fetch(
      `${auth.apiUrl}/b2api/v2/b2_get_upload_url`,
      {
        method: 'POST',
        headers: {
          Authorization: auth.authorizationToken,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          bucketId: Deno.env.get('BACKBLAZE_BUCKET_ID'),
        }),
      }
    )
    const uploadData = await uploadUrlResponse.json()

    return new Response(
      JSON.stringify({
        uploadUrl: uploadData.uploadUrl,
        authorizationToken: uploadData.authorizationToken,
        fileName: path,
        contentType: contentType || 'application/octet-stream',
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
