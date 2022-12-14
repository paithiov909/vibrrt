use extendr_api::prelude::*;

use std::fs::File;
use std::io::BufReader;
use vibrato::dictionary::Dictionary;
use vibrato::Tokenizer;

/// Call Vibrato tokenizer
#[extendr]
fn vbrt(sentence: Vec<String>, dict: String) -> Robj {
    let reader = BufReader::new(File::open(dict).unwrap());
    let dict = Dictionary::read(reader).unwrap();
    let tokenizer = Tokenizer::new(dict);
    let mut worker = tokenizer.new_worker();

    let capacity = sentence.len();
    let mut ids: Vec<u32> = Vec::with_capacity(capacity);
    let mut tokens: Vec<String> = Vec::with_capacity(capacity);
    let mut features: Vec<String> = Vec::with_capacity(capacity);
    let mut wcosts: Vec<i16> = Vec::with_capacity(capacity);
    let mut tcosts: Vec<i32> = Vec::with_capacity(capacity);

    for (i, text) in sentence.iter().enumerate() {
        worker.reset_sentence(text);
        worker.tokenize();
        for j in 0..worker.num_tokens() {
             let t = worker.token(j);
             ids.push(i as _);
             wcosts.push(t.word_cost().clone());
             tcosts.push(t.total_cost().clone());
             tokens.push(t.surface().to_string());
             features.push(t.feature().to_string());
        }
    }
    return data_frame!(
      sentence_id = r!(ids),
      word_cost = r!(wcosts),
      total_cost = r!(tcosts),
      token = r!(tokens),
      feature = r!(features)
    )
}

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
    mod vibrrt;
    fn vbrt;
}
