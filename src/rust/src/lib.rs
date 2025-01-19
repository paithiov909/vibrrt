use std::fs::File;
use vibrato::dictionary::Dictionary;
use vibrato::Tokenizer;

use savvy::savvy;
use savvy::{OwnedListSexp, OwnedIntegerSexp, OwnedStringSexp, StringSexp};
use savvy::NotAvailableValue;

/// Call Vibrato tokenizer
/// @noRd
#[savvy]
fn vbrt(sentence: StringSexp, sys_dic: &str, user_dic: &str) -> savvy::Result<savvy::Sexp>  {
    let reader = File::open(sys_dic).unwrap();
    let dict = if !user_dic.is_empty() {
        let user_dic = File::open(user_dic).unwrap();
        Dictionary::read(reader).unwrap()
            .reset_user_lexicon_from_reader(Some(user_dic)).unwrap()
    } else {
        Dictionary::read(reader).unwrap()
    };
    let tokenizer = Tokenizer::new(dict);
    let mut worker = tokenizer.new_worker();

    let mut ids: Vec<i32> = Vec::new();
    let mut tids: Vec<i32> = Vec::new();
    let mut tokens: Vec<String> = Vec::new();
    let mut features: Vec<String> = Vec::new();
    let mut wcosts: Vec<i32> = Vec::new();
    let mut tcosts: Vec<i32> = Vec::new();

    for (i, text) in sentence.iter().enumerate() {
        if text.is_na() {
            ids.push(i as _);
            tids.push(0);
            tokens.push(String::new());
            features.push(String::new());
            wcosts.push(0);
            tcosts.push(0);
            continue;
        }
        worker.reset_sentence(text);
        worker.tokenize();
        for j in 0..worker.num_tokens() {
            let t = worker.token(j);
            ids.push(i as _);
            tids.push(j as _);
            tokens.push(t.surface().to_string());
            features.push(t.feature().to_string());
            wcosts.push(t.word_cost() as _);
            tcosts.push(t.total_cost());
        }
    }
    let ids_out = OwnedIntegerSexp::try_from_slice(&ids)?;
    let tids_out = OwnedIntegerSexp::try_from_slice(&tids)?;
    let tokens_out = OwnedStringSexp::try_from_slice(&tokens)?;
    let features_out = OwnedStringSexp::try_from_slice(&features)?;
    let wcosts_out = OwnedIntegerSexp::try_from_slice(&wcosts)?;
    let tcosts_out = OwnedIntegerSexp::try_from_slice(&tcosts)?;

    let mut out = OwnedListSexp::new(6, true)?;
    out.set_name_and_value(0, "sentence_id", ids_out)?;
    out.set_name_and_value(1, "token_id", tids_out)?;
    out.set_name_and_value(2, "token", tokens_out)?;
    out.set_name_and_value(3, "feature", features_out)?;
    out.set_name_and_value(4, "word_cost", wcosts_out)?;
    out.set_name_and_value(5, "total_cost", tcosts_out)?;

    Ok(out.into())
}
