use std::fs::File;
use vibrato::dictionary::Dictionary;
use vibrato::Tokenizer;

use savvy::savvy;
use savvy::{OwnedListSexp, OwnedIntegerSexp, OwnedStringSexp, StringSexp};
use savvy::NotAvailableValue;

/// Call vibrato tokenizer
/// @noRd
#[savvy]
fn vbrt(sentence: StringSexp, sys_dic: &str, user_dic: &str, max_grouping_len: i32) -> savvy::Result<savvy::Sexp>  {
    let reader = File::open(sys_dic)?;
    let dict = if !user_dic.is_empty() {
        let user_dic = File::open(user_dic)?;
        Dictionary::read(reader)?
            .reset_user_lexicon_from_reader(Some(user_dic))?
    } else {
        Dictionary::read(reader)?
    };
    let tokenizer = Tokenizer::new(dict)
        .max_grouping_len(max_grouping_len.try_into()?);
    let mut worker = tokenizer.new_worker();

    let mut ids: Vec<i32> = Vec::new();
    let mut tids: Vec<i32> = Vec::new();
    let mut tokens: Vec<String> = Vec::new();
    let mut features: Vec<String> = Vec::new();
    let mut wcosts: Vec<i32> = Vec::new();
    let mut tcosts: Vec<i32> = Vec::new();
    let mut left_id: Vec<i32> = Vec::new();
    let mut right_id: Vec<i32> = Vec::new();

    for (i, text) in sentence.iter().enumerate() {
        if text.is_na() {
            ids.push((i + 1) as _);
            tids.push(0);
            tokens.push(String::new());
            features.push(String::new());
            wcosts.push(0);
            tcosts.push(0);
            left_id.push(0);
            right_id.push(0);
            continue;
        }
        worker.reset_sentence(text);
        worker.tokenize();
        for j in 0..worker.num_tokens() {
            let t = worker.token(j);
            ids.push((i + 1) as _);
            tids.push((j + 1) as _);
            tokens.push(t.surface().to_string());
            features.push(t.feature().to_string());
            wcosts.push(t.word_cost() as _);
            tcosts.push(t.total_cost());
            left_id.push(t.left_id().try_into()?);
            right_id.push(t.right_id().try_into()?);
        }
    }
    let ids_out = OwnedIntegerSexp::try_from_slice(&ids)?;
    let tids_out = OwnedIntegerSexp::try_from_slice(&tids)?;
    let tokens_out = OwnedStringSexp::try_from_slice(&tokens)?;
    let features_out = OwnedStringSexp::try_from_slice(&features)?;
    let wcosts_out = OwnedIntegerSexp::try_from_slice(&wcosts)?;
    let tcosts_out = OwnedIntegerSexp::try_from_slice(&tcosts)?;
    let left_id_out = OwnedIntegerSexp::try_from_slice(&left_id)?;
    let right_id_out = OwnedIntegerSexp::try_from_slice(&right_id)?;

    let mut out = OwnedListSexp::new(8, true)?;
    out.set_name_and_value(0, "sentence_id", ids_out)?;
    out.set_name_and_value(1, "token_id", tids_out)?;
    out.set_name_and_value(2, "token", tokens_out)?;
    out.set_name_and_value(3, "feature", features_out)?;
    out.set_name_and_value(4, "word_cost", wcosts_out)?;
    out.set_name_and_value(5, "total_cost", tcosts_out)?;
    out.set_name_and_value(6, "left_id", left_id_out)?;
    out.set_name_and_value(7, "right_id", right_id_out)?;

    Ok(out.into())
}
