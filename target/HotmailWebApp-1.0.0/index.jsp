<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    // Mock email data (server-side). You can replace with DB/servlet data.
    java.util.List<java.util.Map<String,String>> emails = new java.util.ArrayList<>();
    {
        java.util.Map<String,String> m = new java.util.HashMap<>();
        m.put("from","Alice Johnson <alice@example.com>");
        m.put("subject","Welcome to your new inbox");
        m.put("snippet","Hi — welcome! Here's how to get started...");
        m.put("time","Oct 21");
        m.put("body","Hi there,\n\nWelcome to your new inbox. This demo shows a Hotmail-like GUI using HTML/CSS/JS inside JSP. Enjoy!\n\n— Alice");
        emails.add(m);
    }
    {
        java.util.Map<String,String> m = new java.util.HashMap<>();
        m.put("from","Team Updates <updates@example.com>");
        m.put("subject","Weekly summary: product updates");
        m.put("snippet","This week we shipped several improvements...");
        m.put("time","Oct 19");
        m.put("body","Hello,\n\nHere are the product updates for the week:\n- Improved performance\n- Bug fixes\n\nBest,\nProduct Team");
        emails.add(m);
    }
    {
        java.util.Map<String,String> m = new java.util.HashMap<>();
        m.put("from","Bob Smith <bob@example.com>");
        m.put("subject","Lunch tomorrow?");
        m.put("snippet","Are you free for lunch tomorrow at 1pm?");
        m.put("time","Oct 12");
        m.put("body","Hey,\n\nAre you free for lunch tomorrow at 1pm? Let me know where to meet.\n\nCheers,\nBob");
        emails.add(m);
    }
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>Inbox — Hotmail-like GUI (demo)</title>
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <style>
    /* Simple modern UI styles */
    :root{
      --bg:#f3f6fb; --panel:#ffffff; --accent:#0078d4; --muted:#6b7280;
      --shadow: 0 6px 18px rgba(15,23,42,0.08);
      font-family: Inter, system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial;
    }
    html,body{height:100%; margin:0; background:var(--bg); color:#111827;}
    .app{display:flex; height:100vh; gap:18px; padding:18px; box-sizing:border-box;}
    .sidebar{width:220px; background:var(--panel); border-radius:12px; padding:16px; box-shadow:var(--shadow); display:flex;flex-direction:column; gap:12px;}
    .logo{font-weight:700; color:var(--accent); font-size:18px;}
    .compose-btn{background:var(--accent); color:#fff; border:none; padding:10px 12px; border-radius:10px; cursor:pointer; font-weight:600;}
    .nav{margin-top:6px; display:flex; flex-direction:column; gap:6px;}
    .nav a{padding:8px; border-radius:8px; text-decoration:none; color:#111827; display:flex; justify-content:space-between;}
    .nav a:hover{background:#f1f5f9;}
    .main{flex:1; display:flex; gap:12px; min-width:0;}
    .list-panel{width:420px; background:var(--panel); border-radius:12px; box-shadow:var(--shadow); overflow:auto;}
    .list-header{display:flex; align-items:center; justify-content:space-between; padding:12px 16px; border-bottom:1px solid #eef2f7;}
    .search{padding:8px 10px; border-radius:8px; border:1px solid #e6edf3; width:100%}
    .email-list{list-style:none; margin:0; padding:0;}
    .email-item{padding:12px 16px; border-bottom:1px solid #f1f5f9; cursor:pointer; display:flex; gap:12px; align-items:center;}
    .email-item:hover{background:#f8fafc;}
    .avatar{width:40px;height:40px;border-radius:8px;background:#e6eefc;display:flex;align-items:center;justify-content:center;font-weight:700;color:var(--accent);}
    .email-meta{flex:1; min-width:0;}
    .email-sub{font-weight:600; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;}
    .email-snippet{font-size:13px; color:var(--muted); white-space:nowrap; overflow:hidden; text-overflow:ellipsis;}
    .email-time{font-size:12px;color:var(--muted); margin-left:8px; white-space:nowrap;}
    .viewer{flex:1; background:var(--panel); border-radius:12px; box-shadow:var(--shadow); display:flex; flex-direction:column; overflow:auto;}
    .viewer-header{padding:14px 18px; border-bottom:1px solid #eef2f7; display:flex; justify-content:space-between; align-items:center;}
    .viewer-body{padding:18px; white-space:pre-wrap; line-height:1.5; color:#111827;}
    .controls{display:flex; gap:8px; align-items:center;}
    .btn{padding:8px 10px; border-radius:8px; border:1px solid #e6edf3; background:#fff; cursor:pointer;}
    /* compose modal */
    .modal-backdrop{position:fixed; inset:0; background:rgba(2,6,23,0.48); display:none; align-items:center; justify-content:center; z-index:40;}
    .compose-modal{background:var(--panel); width:600px; border-radius:12px; box-shadow:0 20px 50px rgba(2,6,23,0.4); padding:16px;}
    .field{display:flex; flex-direction:column; gap:6px; margin-bottom:8px;}
    .field input, .field textarea{padding:10px; border-radius:8px; border:1px solid #e6edf3; width:100%; box-sizing:border-box;}
    .close-x{background:transparent;border:0;font-weight:700;cursor:pointer;}
    @media (max-width:900px){
      .sidebar{display:none}
      .list-panel{width:320px}
    }
  </style>
</head>
<body>
  <div class="app">
    <aside class="sidebar">
      <div class="logo">MailBox (demo)</div>
      <button class="compose-btn" id="openComposeBtn">Compose</button>
      <nav class="nav">
        <a href="#">Inbox <span>(3)</span></a>
        <a href="#">Sent</a>
        <a href="#">Drafts</a>
        <a href="#">Archive</a>
        <a href="#">Trash</a>
      </nav>
      <div style="margin-top:auto; font-size:13px; color:var(--muted)">Signed in as <strong>user@example.com</strong></div>
    </aside>

    <main class="main">
      <section class="list-panel">
        <div class="list-header">
          <input type="search" class="search" id="searchInput" placeholder="Search mail..." />
          <div style="width:8px"></div>
        </div>

        <ul class="email-list" id="emailList">
          <% for (int i=0;i<emails.size();i++){
                 java.util.Map<String,String> m = emails.get(i);
          %>
            <li class="email-item" data-index="<%=i%>"
                data-from="<%=m.get("from").replace("\"","&quot;")%>"
                data-subject="<%=m.get("subject").replace("\"","&quot;")%>"
                data-snippet="<%=m.get("snippet").replace("\"","&quot;")%>"
                data-time="<%=m.get("time")%>"
                data-body="<%=m.get("body").replace("\"","&quot;").replace("\n","&#10;")%>"
                onclick="showEmail(event)">
              <div class="avatar"><%=m.get("from").substring(0,1).toUpperCase()%></div>
              <div class="email-meta">
                <div style="display:flex; align-items:center; gap:8px;">
                  <div class="email-sub"><%=m.get("subject")%></div>
                  <div class="email-time"><%=m.get("time")%></div>
                </div>
                <div class="email-snippet"><%=m.get("snippet")%></div>
              </div>
            </li>
          <% } %>
        </ul>
      </section>

      <section class="viewer" id="viewer">
        <div class="viewer-header">
          <div>
            <strong id="viewSubject">Select a message</strong>
            <div id="viewFrom" style="font-size:13px;color:var(--muted)"></div>
          </div>
          <div class="controls">
            <button class="btn" onclick="reply()">Reply</button>
            <button class="btn" onclick="deleteMsg()">Delete</button>
          </div>
        </div>
        <div class="viewer-body" id="viewBody">
          Choose an email from the list to see its contents.
        </div>
      </section>
    </main>
  </div>

  <!-- Compose modal -->
  <div class="modal-backdrop" id="modalBackdrop">
    <div class="compose-modal" role="dialog" aria-modal="true">
      <div style="display:flex; justify-content:space-between; align-items:center;">
        <strong>New Message</strong>
        <button class="close-x" onclick="closeCompose()">✕</button>
      </div>
      <div style="margin-top:10px;">
        <div class="field"><label>To</label><input id="composeTo" placeholder="recipient@example.com" /></div>
        <div class="field"><label>Subject</label><input id="composeSubject" /></div>
        <div class="field"><label>Message</label><textarea id="composeBody" rows="8"></textarea></div>
        <div style="display:flex; justify-content:flex-end; gap:8px;">
          <button class="btn" onclick="closeCompose()">Cancel</button>
          <button class="compose-btn" onclick="sendCompose()">Send</button>
        </div>
      </div>
    </div>
  </div>

  <script>
    // Show email in viewer reading data-* attributes
    function showEmail(e){
      // find the li (in case child clicked)
      var el = e.currentTarget || e.target.closest('.email-item');
      if(!el) return;
      var from = el.dataset.from || '';
      var subject = el.dataset.subject || '';
      var body = el.dataset.body || '';
      var time = el.dataset.time || '';
      document.getElementById('viewSubject').textContent = subject;
      document.getElementById('viewFrom').textContent = from + ' • ' + time;
      document.getElementById('viewBody').textContent = body;
      // highlight selected
      document.querySelectorAll('.email-item').forEach(function(x){ x.style.background=''; });
      el.style.background = '#f3f7fb';
    }

    // Compose modal handlers
    var backdrop = document.getElementById('modalBackdrop');
    document.getElementById('openComposeBtn').addEventListener('click', openCompose);
    function openCompose(){
      backdrop.style.display = 'flex';
      document.getElementById('composeTo').focus();
    }
    function closeCompose(){
      backdrop.style.display = 'none';
      document.getElementById('composeTo').value = '';
      document.getElementById('composeSubject').value = '';
      document.getElementById('composeBody').value = '';
    }
    function sendCompose(){
      // In a real app you'd POST to a servlet. Here we just simulate.
      alert('Message would be sent (demo). To: ' + document.getElementById('composeTo').value);
      closeCompose();
    }

    function reply(){
      var subject = document.getElementById('viewSubject').textContent;
      if(!subject || subject === 'Select a message'){ alert('Pick a message to reply to.'); return; }
      openCompose();
      document.getElementById('composeSubject').value = 'Re: ' + subject;
    }
    function deleteMsg(){
      alert('Delete (demo): this would remove the message on the server in a real app.');
    }

    // Simple search (client-side)
    document.getElementById('searchInput').addEventListener('input', function(){
      var q = this.value.trim().toLowerCase();
      document.querySelectorAll('.email-item').forEach(function(li){
        var subject = li.dataset.subject.toLowerCase();
        var from = li.dataset.from.toLowerCase();
        var snippet = li.dataset.snippet.toLowerCase();
        if(!q || subject.indexOf(q) !== -1 || from.indexOf(q) !== -1 || snippet.indexOf(q) !== -1){
          li.style.display = '';
        } else {
          li.style.display = 'none';
        }
      });
    });
  </script>
</body>
</html>
