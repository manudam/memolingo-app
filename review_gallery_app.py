import streamlit as st
import pandas as pd
import os

st.set_page_config(layout="wide", page_title="Memolingo Image Review")

csv_file = "assets/memolingo/data/words_list_full.csv"
image_dir = "assets/memolingo/images"
flag_file = "flagged_images.txt"

@st.cache_data
def load_data():
    df = pd.read_csv(csv_file)
    return df

df = load_data()

if 'flagged' not in st.session_state:
    if os.path.exists(flag_file):
        with open(flag_file, 'r') as f:
            st.session_state.flagged = set(f.read().splitlines())
    else:
        st.session_state.flagged = set()

def toggle_flag(word):
    if word in st.session_state.flagged:
        st.session_state.flagged.remove(word)
    else:
        st.session_state.flagged.add(word)
    with open(flag_file, 'w') as f:
        f.write("\n".join(st.session_state.flagged))

ITEMS_PER_PAGE = 50
total_pages = max(1, (len(df) + ITEMS_PER_PAGE - 1) // ITEMS_PER_PAGE)

if 'page' not in st.session_state:
    st.session_state.page = 1

st.title("Memolingo Local Image Review Gallery")
st.write(f"Total Words: {len(df)} | Flagged so far: {len(st.session_state.flagged)}")

col_f1, col_f2 = st.columns(2)
with col_f1:
    show_only_flagged = st.checkbox("🔍 Show ONLY flagged images", value=False)
with col_f2:
    if st.button("🧹 Clear All Flags"):
        st.session_state.flagged = set()
        with open(flag_file, 'w') as f:
            f.write("")
        st.rerun()

if show_only_flagged:
    df = df[df['English'].apply(lambda w: str(w) in st.session_state.flagged)]
    
total_pages = max(1, (len(df) + ITEMS_PER_PAGE - 1) // ITEMS_PER_PAGE)
if st.session_state.page > total_pages:
    st.session_state.page = 1

col1, col2, col3 = st.columns([1, 2, 1])
with col1:
    if st.button("⬅️ Previous Page") and st.session_state.page > 1:
        st.session_state.page -= 1
        st.rerun()
with col2:
    st.write(f"### Page {st.session_state.page} of {total_pages}")
with col3:
    if st.button("Next Page ➡️") and st.session_state.page < total_pages:
        st.session_state.page += 1
        st.rerun()

st.markdown("---")

start_idx = (st.session_state.page - 1) * ITEMS_PER_PAGE
end_idx = min(start_idx + ITEMS_PER_PAGE, len(df))
current_items = df.iloc[start_idx:end_idx]

cols = st.columns(5)
for idx, row in current_items.reset_index().iterrows():
    word = str(row['English'])
    filename = str(row['Filename'])
    category = str(row['Category'])
    img_path = os.path.join(image_dir, filename)
    
    col_idx = idx % 5
    with cols[col_idx]:
        st.markdown(f"**{word.capitalize()}** ({category})")
        if os.path.exists(img_path):
            st.image(img_path, use_container_width=True)
        else:
            st.warning("Image missing")
            
        is_flagged = word in st.session_state.flagged
        btn_label = "✅ Unflag" if is_flagged else "🚩 Flag for Rework"
        btn_type = "primary" if is_flagged else "secondary"
        
        if st.button(btn_label, key=f"flag_{word}", type=btn_type, use_container_width=True):
            toggle_flag(word)
            st.rerun()
        st.markdown("---")
