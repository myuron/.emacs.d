(eval-when-compile
  (require 'use-package))

(eval-and-compile
  (setopt use-package-ensure-function #'(lambda (&rest args) t))
  (setopt use-package-always-defer t)
  (setopt use-package-compute-statistics t))

(use-package doom-themes
  :ensure t
  :custom
  (doom-themes-enable-bold t)
  (doom-themes-enable-italic t)
  :hook (after-init-hook . (lambda () (load-theme 'doom-one t))))
