// Copyright (c) 2018-2024, The Nerva Project
// Copyright (c) 2014-2024, The Monero Project
// 
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
// 
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 
// Parts of this file are originally copyright (c) 2012-2013 The Cryptonote developers

#pragma once

#include <stddef.h>
#include <iostream>

#include "common/pod-class.h"
#include "generic-ops.h"
#include "hex.h"
#include "span.h"

namespace crypto {

  extern "C" {
#include "hash-ops.h"
  }

#pragma pack(push, 1)
  POD_CLASS hash {
    char data[HASH_SIZE];
  };
  POD_CLASS hash8 {
    char data[8];
  };
#pragma pack(pop)

  static_assert(sizeof(hash) == HASH_SIZE, "Invalid structure size");
  static_assert(sizeof(hash8) == 8, "Invalid structure size");

  /*
    Cryptonight hash functions
  */

  inline void cn_fast_hash(const void *data, std::size_t length, hash &hash) {
    cn_fast_hash(data, length, reinterpret_cast<char *>(&hash));
  }

  inline hash cn_fast_hash(const void *data, std::size_t length) {
    hash h;
    cn_fast_hash(data, length, reinterpret_cast<char *>(&h));
    return h;
  }

  inline void cn_slow_hash_v11(cn_hash_context_t *context, const void *data, size_t length, hash &hash, size_t iters, uint8_t init_size_blk, uint16_t xx, uint16_t yy) {
    cn_slow_hash_v11(context, data, length, reinterpret_cast<char *>(&hash), iters, init_size_blk, xx, yy);
  }

  inline void cn_slow_hash_v10(cn_hash_context_t *context, const void *data, size_t length, hash &hash, size_t iters, uint8_t init_size_blk, uint16_t xx, uint16_t yy, uint16_t zz, uint16_t ww) {
    cn_slow_hash_v10(context, data, length, reinterpret_cast<char *>(&hash), iters, init_size_blk, xx, yy, zz, ww);
  }
 
  inline void cn_slow_hash_v9(cn_hash_context_t *context, const void *data, size_t length, hash &hash, size_t iters) {
    cn_slow_hash_v9(context, data, length, reinterpret_cast<char *>(&hash), iters);
  }

  inline void cn_slow_hash_v7_8(cn_hash_context_t *context, const void *data, size_t length, hash &hash, size_t iters) {
    cn_slow_hash_v7_8(context, data, length, reinterpret_cast<char *>(&hash), iters);
  }

  inline void cn_slow_hash(cn_hash_context_t *context, const void *data, std::size_t length, hash &hash, int variant = 0, size_t iters = 0x40000) {
    cn_slow_hash(context, data, length, reinterpret_cast<char *>(&hash), variant, 0, iters);
  }

  inline void tree_hash(const hash *hashes, std::size_t count, hash &root_hash) {
    tree_hash(reinterpret_cast<const char (*)[HASH_SIZE]>(hashes), count, reinterpret_cast<char *>(&root_hash));
  }

  inline std::ostream &operator <<(std::ostream &o, const crypto::hash &v) {
    epee::to_hex::formatted(o, epee::as_byte_span(v)); return o;
  }
  inline std::ostream &operator <<(std::ostream &o, const crypto::hash8 &v) {
    epee::to_hex::formatted(o, epee::as_byte_span(v)); return o;
  }

  constexpr static crypto::hash null_hash = {};
  constexpr static crypto::hash8 null_hash8 = {};
}

CRYPTO_MAKE_HASHABLE(hash)
CRYPTO_MAKE_COMPARABLE(hash8)
