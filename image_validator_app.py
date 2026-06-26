import streamlit as st
import pandas as pd
import os
import requests
from duckduckgo_search import DDGS

st.set_page_config(layout="wide")

csv_file = "assets/memolingo/data/words_list_full.csv"
image_dir = "assets/memolingo/images"

if 'current_index' not in st.session_state:
    st.session_state.current_index = 0
if 'df' not in st.session_state:
    st.session_state.df = pd.read_csv(csv_file)
if 'urls' not in st.session_state:
    st.session_state.urls = []

df = st.session_state.df

st.title("Memolingo Image Validator")

if st.session_state.current_index >= len(df):
    st.success("All done! You have reviewed all images.")
    st.stop()

progress = st.session_state.current_index / len(df)
st.progress(progress)
st.write(f"Validating word **{st.session_state.current_index + 1}** of **{len(df)}**")

row = df.iloc[st.session_state.current_index]
category = row.iloc[0]
filename = row.iloc[3]
word = row.iloc[4]

st.header(f"Word: {word.capitalize()} (Category: {category})")

current_img_path = os.path.join(image_dir, filename)
if os.path.exists(current_img_path):
    st.subheader("Current Image:")
    st.image(current_img_path, width=200)
else:
    st.warning("No image currently exists for this word!")

def fetch_images(query):
    try:
        # Search for high quality images
        results = DDGS().images(f"high quality photography {query}", max_results=5)
        return [r['image'] for r in results]
    except Exception as e:
        st.error(f"Search failed: {e}")
        return []

if not st.session_state.urls:
    with st.spinner("Fetching image candidates from DuckDuckGo..."):
        st.session_state.urls = fetch_images(word)

def select_image(url):
    try:
        response = requests.get(url, timeout=10)
        with open(current_img_path, 'wb') as f:
            f.write(response.content)
    except Exception as e:
        st.error(f"Failed to download image: {e}")
        return
    st.session_state.urls = []
    st.session_state.current_index += 1

st.subheader("High-Quality Options:")
cols = st.columns(5)
for i, url in enumerate(st.session_state.urls):
    with cols[i]:
        try:
            st.image(url, use_container_width=True)
            if st.button(f"Select #{i+1}", key=f"btn_{i}_{st.session_state.current_index}"):
                select_image(url)
                st.rerun()
        except Exception:
            st.write("Image broken")

st.markdown("---")
col1, col2 = st.columns(2)
with col1:
    if st.button("Keep Current Image & Next ➡️", type="primary", use_container_width=True):
        st.session_state.urls = []
        st.session_state.current_index += 1
        st.rerun()
with col2:
    if st.button("⬅️ Go Back", use_container_width=True):
        if st.session_state.current_index > 0:
            st.session_state.urls = []
            st.session_state.current_index -= 1
            st.rerun()
