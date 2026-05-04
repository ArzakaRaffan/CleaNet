extends Node

# ── SHA-512 constants ─────────────────────────────────────────────────────────
const K: Array = [
	0x428a2f98, 0xd728ae22, 0x71374491, 0x23ef65cd, 0xb5c0fbcf, 0xec4d3b2f, 0xe9b5dba5, 0x8189dbbc,
	0x3956c25b, 0xf348b538, 0x59f111f1, 0xb605d019, 0x923f82a4, 0xaf194f9b, 0xab1c5ed5, 0xda6d8118,
	0xd807aa98, 0xa3030242, 0x12835b01, 0x45706fbe, 0x243185be, 0x4ee4b28c, 0x550c7dc3, 0xd5ffb4e2,
	0x72be5d74, 0xf27b896f, 0x80deb1fe, 0x3b1696b1, 0x9bdc06a7, 0x25c71235, 0xc19bf174, 0xcf692694,
	0xe49b69c1, 0x9ef14ad2, 0xefbe4786, 0x384f25e3, 0x0fc19dc6, 0x8b8cd5b5, 0x240ca1cc, 0x77ac9c65,
	0x2de92c6f, 0x592b0275, 0x4a7484aa, 0x6ea6e483, 0x5cb0a9dc, 0xbd41fbd4, 0x76f988da, 0x831153b5,
	0x983e5152, 0xee66dfab, 0xa831c66d, 0x2db43210, 0xb00327c8, 0x98fb213f, 0xbf597fc7, 0xbeef0ee4,
	0xc6e00bf3, 0x3da88fc2, 0xd5a79147, 0x930aa725, 0x06ca6351, 0xe003826f, 0x14292967, 0x0a0e6e70,
	0x27b70a85, 0x46d22ffc, 0x2e1b2138, 0x5c26c926, 0x4d2c6dfc, 0x5ac42aed, 0x53380d13, 0x9d95b3df,
	0x650a7354, 0x8baf63de, 0x766a0abb, 0x3c77b2a8, 0x81c2c92e, 0x47edaee6, 0x92722c85, 0x1482353b,
	0xa2bfe8a1, 0x4cf10364, 0xa81a664b, 0xbc423001, 0xc24b8b70, 0xd0f89791, 0xc76c51a3, 0x0654be30,
	0xd192e819, 0xd6ef5218, 0xd6990624, 0x5565a910, 0xf40e3585, 0x5771202a, 0x106aa070, 0x32bbd1b8,
	0x19a4c116, 0xb8d2d0c8, 0x1e376c08, 0x5141ab53, 0x2748774c, 0xdf8eeb99, 0x34b0bcb5, 0xe19b48a8,
	0x391c0cb3, 0xc5c95a63, 0x4ed8aa4a, 0xe3418acb, 0x5b9cca4f, 0x7763e373, 0x682e6ff3, 0xd6b2b8a3,
	0x748f82ee, 0x5defb2fc, 0x78a5636f, 0x43172f60, 0x84c87814, 0xa1f0ab72, 0x8cc70208, 0x1a6439ec,
	0x90befffa, 0x23631e28, 0xa4506ceb, 0xde82bde9, 0xbef9a3f7, 0xb2c67915, 0xc67178f2, 0xe372532b,
	0xca273ece, 0xea26619c, 0xd186b8c7, 0x21c0c207, 0xeada7dd6, 0xcde0eb1e, 0xf57d4f7f, 0xee6ed178,
	0x06f067aa, 0x72176fba, 0x0a637dc5, 0xa2c898a6, 0x113f9804, 0xbef90dae, 0x1b710b35, 0x131c471b,
	0x28db77f5, 0x23047d84, 0x32caab7b, 0x40c72493, 0x3c9ebe0a, 0x15c9bebc, 0x431d67c4, 0x9c100d4c,
	0x4cc5d4be, 0xcb3e42b6, 0x597f299c, 0xfc657e2a, 0x5fcb6fab, 0x3ad6faec, 0x6c44198c, 0x4a475817,
]

# Initial hash values (first 32 bits of fractional parts of sqrt of 9th-16th primes)
const H0_HI := 0x6a09e667; const H0_LO := 0xf3bcc908
const H1_HI := 0xbb67ae85; const H1_LO := 0x84caa73b
const H2_HI := 0x3c6ef372; const H2_LO := 0xfe94f82b
const H3_HI := 0xa54ff53a; const H3_LO := 0x5f1d36f1
const H4_HI := 0x510e527f; const H4_LO := 0xade682d1
const H5_HI := 0x9b05688c; const H5_LO := 0x2b3e6c1f
const H6_HI := 0x1f83d9ab; const H6_LO := 0xfb41bd6b
const H7_HI := 0x5be0cd19; const H7_LO := 0x137e2179

# ── 64-bit helpers (represented as [hi, lo] pairs) ───────────────────────────

func _ready():
	var test = hmac_sha512_base64("key", "message")
	print("SHA512 TEST: ", test)

func _add64(ah: int, al: int, bh: int, bl: int) -> Array:
	var lo := (al + bl) & 0xFFFFFFFF
	var carry := 1 if (al + bl) > 0xFFFFFFFF else 0
	var hi := (ah + bh + carry) & 0xFFFFFFFF
	return [hi, lo]

func _rotr64(hi: int, lo: int, n: int) -> Array:
	if n < 32:
		return [
			((hi >> n) | (lo << (32 - n))) & 0xFFFFFFFF,
			((lo >> n) | (hi << (32 - n))) & 0xFFFFFFFF
		]
	else:
		n -= 32
		return [
			((lo >> n) | (hi << (32 - n))) & 0xFFFFFFFF,
			((hi >> n) | (lo << (32 - n))) & 0xFFFFFFFF
		]

func _shr64(hi: int, lo: int, n: int) -> Array:
	if n < 32:
		return [(hi >> n) & 0xFFFFFFFF, ((lo >> n) | (hi << (32 - n))) & 0xFFFFFFFF]
	else:
		return [0, (hi >> (n - 32)) & 0xFFFFFFFF]

func _xor64(ah: int, al: int, bh: int, bl: int) -> Array:
	return [ah ^ bh, al ^ bl]

func _and64(ah: int, al: int, bh: int, bl: int) -> Array:
	return [ah & bh, al & bl]

func _not64(hi: int, lo: int) -> Array:
	return [(~hi) & 0xFFFFFFFF, (~lo) & 0xFFFFFFFF]

# ── SHA-512 core ──────────────────────────────────────────────────────────────

func _sha512(data: PackedByteArray) -> PackedByteArray:
	var msg := PackedByteArray(data)
	var orig_len_bits_lo := (data.size() * 8) & 0xFFFFFFFF
	var orig_len_bits_hi := (data.size() >> 29) & 0xFFFFFFFF

	msg.append(0x80)
	while msg.size() % 128 != 112:
		msg.append(0x00)

	for _i in range(8):
		msg.append(0x00)
	msg.append((orig_len_bits_hi >> 24) & 0xFF)
	msg.append((orig_len_bits_hi >> 16) & 0xFF)
	msg.append((orig_len_bits_hi >> 8) & 0xFF)
	msg.append(orig_len_bits_hi & 0xFF)
	msg.append((orig_len_bits_lo >> 24) & 0xFF)
	msg.append((orig_len_bits_lo >> 16) & 0xFF)
	msg.append((orig_len_bits_lo >> 8) & 0xFF)
	msg.append(orig_len_bits_lo & 0xFF)

	# Initial hash state
	var hh := [[H0_HI, H0_LO], [H1_HI, H1_LO], [H2_HI, H2_LO], [H3_HI, H3_LO],
			   [H4_HI, H4_LO], [H5_HI, H5_LO], [H6_HI, H6_LO], [H7_HI, H7_LO]]

	# Process each 1024-bit (128-byte) chunk
	var num_chunks := msg.size() / 128
	for chunk_i in range(num_chunks):
		var base := chunk_i * 128
		var w: Array = []

		# Prepare message schedule
		for i in range(16):
			var o := base + i * 8
			var whi := (msg[o] << 24) | (msg[o+1] << 16) | (msg[o+2] << 8) | msg[o+3]
			var wlo := (msg[o+4] << 24) | (msg[o+5] << 16) | (msg[o+6] << 8) | msg[o+7]
			w.append([whi, wlo])

		for i in range(16, 80):
			var s0 := _xor64(
				_rotr64(w[i-15][0], w[i-15][1], 1)[0], _rotr64(w[i-15][0], w[i-15][1], 1)[1],
				_rotr64(w[i-15][0], w[i-15][1], 8)[0], _rotr64(w[i-15][0], w[i-15][1], 8)[1]
			)
			s0 = _xor64(s0[0], s0[1], _shr64(w[i-15][0], w[i-15][1], 7)[0], _shr64(w[i-15][0], w[i-15][1], 7)[1])

			var s1 := _xor64(
				_rotr64(w[i-2][0], w[i-2][1], 19)[0], _rotr64(w[i-2][0], w[i-2][1], 19)[1],
				_rotr64(w[i-2][0], w[i-2][1], 61)[0], _rotr64(w[i-2][0], w[i-2][1], 61)[1]
			)
			s1 = _xor64(s1[0], s1[1], _shr64(w[i-2][0], w[i-2][1], 6)[0], _shr64(w[i-2][0], w[i-2][1], 6)[1])

			var ww := _add64(w[i-16][0], w[i-16][1], s0[0], s0[1])
			ww = _add64(ww[0], ww[1], w[i-7][0], w[i-7][1])
			ww = _add64(ww[0], ww[1], s1[0], s1[1])
			w.append(ww)

		# Working variables
		var a := [hh[0][0], hh[0][1]]
		var b := [hh[1][0], hh[1][1]]
		var c := [hh[2][0], hh[2][1]]
		var d := [hh[3][0], hh[3][1]]
		var e := [hh[4][0], hh[4][1]]
		var f := [hh[5][0], hh[5][1]]
		var g := [hh[6][0], hh[6][1]]
		var h := [hh[7][0], hh[7][1]]

		for i in range(80):
			var S1 := _xor64(
				_rotr64(e[0], e[1], 14)[0], _rotr64(e[0], e[1], 14)[1],
				_rotr64(e[0], e[1], 18)[0], _rotr64(e[0], e[1], 18)[1]
			)
			S1 = _xor64(S1[0], S1[1], _rotr64(e[0], e[1], 41)[0], _rotr64(e[0], e[1], 41)[1])

			var ch := _xor64(
				_and64(e[0], e[1], f[0], f[1])[0], _and64(e[0], e[1], f[0], f[1])[1],
				_and64(_not64(e[0], e[1])[0], _not64(e[0], e[1])[1], g[0], g[1])[0],
				_and64(_not64(e[0], e[1])[0], _not64(e[0], e[1])[1], g[0], g[1])[1]
			)

			var temp1 := _add64(h[0], h[1], S1[0], S1[1])
			temp1 = _add64(temp1[0], temp1[1], ch[0], ch[1])
			temp1 = _add64(temp1[0], temp1[1], K[i * 2], K[i * 2 + 1])
			temp1 = _add64(temp1[0], temp1[1], w[i][0], w[i][1])

			var S0 := _xor64(
				_rotr64(a[0], a[1], 28)[0], _rotr64(a[0], a[1], 28)[1],
				_rotr64(a[0], a[1], 34)[0], _rotr64(a[0], a[1], 34)[1]
			)
			S0 = _xor64(S0[0], S0[1], _rotr64(a[0], a[1], 39)[0], _rotr64(a[0], a[1], 39)[1])

			var maj := _xor64(
				_and64(a[0], a[1], b[0], b[1])[0], _and64(a[0], a[1], b[0], b[1])[1],
				_and64(a[0], a[1], c[0], c[1])[0], _and64(a[0], a[1], c[0], c[1])[1]
			)
			maj = _xor64(maj[0], maj[1], _and64(b[0], b[1], c[0], c[1])[0], _and64(b[0], b[1], c[0], c[1])[1])

			var temp2 := _add64(S0[0], S0[1], maj[0], maj[1])

			h = g; g = f; f = e
			e = _add64(d[0], d[1], temp1[0], temp1[1])
			d = c; c = b; b = a
			a = _add64(temp1[0], temp1[1], temp2[0], temp2[1])

		hh[0] = _add64(hh[0][0], hh[0][1], a[0], a[1])
		hh[1] = _add64(hh[1][0], hh[1][1], b[0], b[1])
		hh[2] = _add64(hh[2][0], hh[2][1], c[0], c[1])
		hh[3] = _add64(hh[3][0], hh[3][1], d[0], d[1])
		hh[4] = _add64(hh[4][0], hh[4][1], e[0], e[1])
		hh[5] = _add64(hh[5][0], hh[5][1], f[0], f[1])
		hh[6] = _add64(hh[6][0], hh[6][1], g[0], g[1])
		hh[7] = _add64(hh[7][0], hh[7][1], h[0], h[1])

	# Produce final hash bytes
	var digest := PackedByteArray()
	for pair in hh:
		digest.append((pair[0] >> 24) & 0xFF)
		digest.append((pair[0] >> 16) & 0xFF)
		digest.append((pair[0] >> 8) & 0xFF)
		digest.append(pair[0] & 0xFF)
		digest.append((pair[1] >> 24) & 0xFF)
		digest.append((pair[1] >> 16) & 0xFF)
		digest.append((pair[1] >> 8) & 0xFF)
		digest.append(pair[1] & 0xFF)
	return digest

# ── HMAC-SHA512 ───────────────────────────────────────────────────────────────

func hmac_sha512_base64(secret: String, message: String) -> String:
	var key := secret.to_utf8_buffer()
	var msg := message.to_utf8_buffer()

	const BLOCK_SIZE := 128  # SHA-512 block size is 128 bytes

	if key.size() > BLOCK_SIZE:
		key = _sha512(key)
	while key.size() < BLOCK_SIZE:
		key.append(0x00)

	var i_key_pad := PackedByteArray()
	var o_key_pad := PackedByteArray()
	for i in BLOCK_SIZE:
		i_key_pad.append(key[i] ^ 0x36)
		o_key_pad.append(key[i] ^ 0x5C)

	var inner := PackedByteArray()
	inner.append_array(i_key_pad)
	inner.append_array(msg)

	var outer := PackedByteArray()
	outer.append_array(o_key_pad)
	outer.append_array(_sha512(inner))

	return Marshalls.raw_to_base64(_sha512(outer))
